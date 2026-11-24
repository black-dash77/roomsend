import Foundation
import Network
import OSLog

/// What answers a request. Called once per connection, off the main actor.
nonisolated protocol HTTPHandler: Sendable {
    func handle(_ request: HTTPRequestHead, body: HTTPBody, from host: String?) async -> HTTPResponse
}

nonisolated enum HTTPConnectionError: Error {
    case closed, malformed, tooLarge
}

/// One TCP (or TLS) connection: reads one request, lets the handler answer, closes.
/// The buffer is only touched by the single task that serves the connection, in order.
nonisolated final class HTTPConnection: @unchecked Sendable {
    private let connection: NWConnection
    private var buffer = Data()

    private static let chunkSize = 64 * 1024
    private static let maxHeadSize = 32 * 1024
    private static let fileChunkSize = 1024 * 1024

    init(_ connection: NWConnection) {
        self.connection = connection
    }

    func serve(on queue: DispatchQueue, with handler: some HTTPHandler) {
        connection.start(queue: queue)
        Task {
            do {
                let head = try await readHead()
                let body = HTTPBody(connection: self, length: head.contentLength)
                let response = await handler.handle(head, body: body, from: connection.endpoint.hostString)
                try await send(response)
            } catch {
                Log.server.debug("Connection ended: \(String(describing: error))")
            }
            connection.cancel()
        }
    }

    /// Bytes already received beyond what was consumed, then the next chunk from the network.
    func nextChunk() async throws -> Data {
        if !buffer.isEmpty {
            defer { buffer.removeAll() }
            return buffer
        }
        return try await receive()
    }

    private func readHead() async throws -> HTTPRequestHead {
        while buffer.range(of: HTTPRequestHead.terminator) == nil {
            guard buffer.count < Self.maxHeadSize else { throw HTTPConnectionError.tooLarge }
            buffer.append(try await receive())
        }
        guard let end = buffer.range(of: HTTPRequestHead.terminator),
              let head = HTTPRequestHead(buffer[..<end.lowerBound]) else { throw HTTPConnectionError.malformed }
        buffer = Data(buffer[end.upperBound...])
        return head
    }

    private func receive() async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            connection.receive(minimumIncompleteLength: 1, maximumLength: Self.chunkSize) { data, _, isComplete, error in
                if let error { return continuation.resume(throwing: error) }
                if let data, !data.isEmpty { return continuation.resume(returning: data) }
                continuation.resume(throwing: isComplete ? HTTPConnectionError.closed : HTTPConnectionError.malformed)
            }
        }
    }

    private func send(_ response: HTTPResponse) async throws {
        switch response.body {
        case .empty:
            try await write(response.head)
        case let .data(data, _):
            try await write(response.head + data)
        case let .file(url, _, _, _):
            try await write(response.head)
            try await stream(url)
        }
    }

    private func stream(_ url: URL) async throws {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        while let chunk = try handle.read(upToCount: Self.fileChunkSize), !chunk.isEmpty {
            try await write(chunk)
        }
    }

    private func write(_ data: Data) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            connection.send(content: data, completion: .contentProcessed { error in
                if let error { continuation.resume(throwing: error) } else { continuation.resume() }
            })
        }
    }
}

/// The body of a request, read lazily from its connection.
nonisolated struct HTTPBody: Sendable {
    let connection: HTTPConnection
    let length: Int64

    /// A small body (JSON), refused beyond `limit` bytes.
    func data(limit: Int64) async throws -> Data {
        guard length <= limit else { throw HTTPConnectionError.tooLarge }
        var data = Data()
        while Int64(data.count) < length { data.append(try await connection.nextChunk()) }
        return data.prefix(Int(length))
    }

    /// A file body, written to `url` as it arrives; never held whole in memory.
    @concurrent
    func write(to url: URL) async throws {
        FileManager.default.createFile(atPath: url.path(percentEncoded: false), contents: nil)
        let handle = try FileHandle(forWritingTo: url)
        defer { try? handle.close() }
        var written: Int64 = 0
        while written < length {
            let chunk = try await connection.nextChunk()
            let slice = chunk.prefix(Int(min(Int64(chunk.count), length - written)))
            try handle.write(contentsOf: slice)
            written += Int64(slice.count)
        }
    }
}
