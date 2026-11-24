import Foundation
import OSLog

/// Sends files to a LocalSend receiver with the Upload API (protocol v2.2, section 4):
/// `prepare-upload` with the metadata (and the PIN when asked), one `upload` per accepted file,
/// `cancel` when the person stops.
nonisolated struct TransferService: Sendable {
    /// What the sender learns while it sends: the receiver's session, then the bytes gone.
    struct Events: Sendable {
        let onSession: @Sendable (String) async -> Void
        let onBytes: @Sendable (Int64) async -> Void
    }

    let sender: DeviceInfo

    private static let jsonType = "application/json"
    private static let binaryType = "application/octet-stream"

    func send(
        _ items: [OutgoingItem], to device: NearbyDevice, pin: String?, events: Events
    ) async throws(TransferError) {
        guard let apiURL = device.apiURL else { throw .unreachable }
        let session = Self.session(for: device)
        defer { session.finishTasksAndInvalidate() }
        guard let prepared = try await prepare(items, at: apiURL, pin: pin, session: session) else { return }
        await events.onSession(prepared.sessionId)
        var sent: Int64 = 0
        for item in items {
            guard let token = prepared.files[item.id] else { continue }
            let request = Self.uploadRequest(item, token: token, sessionID: prepared.sessionId, at: apiURL)
            let progress = UploadProgress(base: sent, report: events.onBytes)
            let (_, status) = try await perform { try await session.upload(for: request, fromFile: item.fileURL, delegate: progress) }
            try Self.check(status)
            sent += item.size
            await events.onBytes(sent)
        }
    }

    /// Tells the receiver to drop the session; best effort, the person already stopped.
    static func cancel(session id: String, on device: NearbyDevice) async {
        guard let url = device.apiURL?.appending(path: "cancel").appending(queryItems: [URLQueryItem(name: "sessionId", value: id)]) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let session = Self.session(for: device)
        defer { session.finishTasksAndInvalidate() }
        do {
            _ = try await session.data(for: request)
        } catch {
            Log.transfer.info("Cancel not delivered: \(error.localizedDescription)")
        }
    }

    private static func session(for device: NearbyDevice) -> URLSession {
        URLSession(configuration: .ephemeral, delegate: FingerprintTrust(expectedFingerprint: device.id), delegateQueue: nil)
    }

    /// Returns nil when the receiver needs nothing (HTTP 204).
    private func prepare(
        _ items: [OutgoingItem], at apiURL: URL, pin: String?, session: URLSession
    ) async throws(TransferError) -> PrepareUploadResponse? {
        var url = apiURL.appending(path: "prepare-upload")
        if let pin, !pin.isEmpty { url.append(queryItems: [URLQueryItem(name: "pin", value: pin)]) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(Self.jsonType, forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONEncoder().encode(PrepareUploadRequest(sender: sender, items: items))
        } catch {
            Log.transfer.error("prepare-upload body not encoded: \(error.localizedDescription)")
            throw .invalidResponse
        }
        let (data, status) = try await perform { try await session.data(for: request) }
        if status == HTTPStatus.noContent { return nil }
        try Self.check(status)
        do {
            return try JSONDecoder().decode(PrepareUploadResponse.self, from: data)
        } catch {
            Log.transfer.error("prepare-upload answer unreadable: \(error.localizedDescription)")
            throw .invalidResponse
        }
    }

    private static func uploadRequest(_ item: OutgoingItem, token: String, sessionID: String, at apiURL: URL) -> URLRequest {
        var request = URLRequest(url: apiURL.appending(path: "upload").appending(queryItems: [
            URLQueryItem(name: "sessionId", value: sessionID),
            URLQueryItem(name: "fileId", value: item.id),
            URLQueryItem(name: "token", value: token),
        ]))
        request.httpMethod = "POST"
        request.setValue(binaryType, forHTTPHeaderField: "Content-Type")
        return request
    }

    private func perform(_ call: () async throws -> (Data, URLResponse)) async throws(TransferError) -> (Data, Int) {
        do {
            let (data, response) = try await call()
            guard let http = response as? HTTPURLResponse else { throw TransferError.invalidResponse }
            return (data, http.statusCode)
        } catch let error as TransferError {
            throw error
        } catch is CancellationError {
            throw .cancelled
        } catch let error as URLError where error.code == .cancelled {
            throw .cancelled
        } catch {
            Log.transfer.error("Receiver unreachable: \(error.localizedDescription)")
            throw .unreachable
        }
    }

    private static func check(_ status: Int) throws(TransferError) {
        switch status {
        case HTTPStatus.ok: return
        case HTTPStatus.unauthorized: throw .pinRequired
        case HTTPStatus.forbidden: throw .rejected
        case HTTPStatus.conflict, HTTPStatus.tooManyRequests: throw .busy
        default: throw .receiver(code: status)
        }
    }
}

/// Reports the bytes of one upload as they leave, on top of those already sent.
nonisolated final class UploadProgress: NSObject, URLSessionTaskDelegate, Sendable {
    private let base: Int64
    private let report: @Sendable (Int64) async -> Void

    init(base: Int64, report: @escaping @Sendable (Int64) async -> Void) {
        self.base = base
        self.report = report
    }

    func urlSession(
        _ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64, totalBytesExpectedToSend: Int64
    ) {
        let total = base + totalBytesSent
        Task { await report(total) }
    }
}

nonisolated enum HTTPStatus {
    static let ok = 200
    static let noContent = 204
    static let unauthorized = 401
    static let forbidden = 403
    static let conflict = 409
    static let tooManyRequests = 429
}
