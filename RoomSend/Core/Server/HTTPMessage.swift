import Foundation

/// The line and headers of an HTTP/1.1 request, read up to the blank line.
nonisolated struct HTTPRequestHead: Sendable {
    let method: String
    let path: String
    let query: [String: String]
    let headers: [String: String]

    static let terminator = Data("\r\n\r\n".utf8)
    private static let lineBreak = "\r\n"

    var contentLength: Int64 { Int64(headers["content-length"] ?? "") ?? 0 }

    /// Nil when the bytes are not an HTTP request line followed by headers.
    init?(_ data: Data) {
        guard let text = String(data: data, encoding: .utf8) else { return nil }
        var lines = text.components(separatedBy: Self.lineBreak)
        let parts = lines.removeFirst().split(separator: " ")
        guard parts.count >= 2 else { return nil }
        let components = URLComponents(string: String(parts[1]))
        method = parts[0].uppercased()
        path = components?.path ?? "/"
        query = Dictionary((components?.queryItems ?? []).map { ($0.name, $0.value ?? "") }) { first, _ in first }
        headers = Dictionary(lines.compactMap(Self.header)) { first, _ in first }
    }

    private static func header(_ line: String) -> (String, String)? {
        guard let colon = line.firstIndex(of: ":") else { return nil }
        let name = line[..<colon].trimmingCharacters(in: .whitespaces).lowercased()
        let value = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        return (name, value)
    }
}

/// An answer: a status and a body held in memory, or a file streamed from disk.
nonisolated struct HTTPResponse: Sendable {
    enum Body: Sendable {
        case empty
        case data(Data, type: String)
        case file(URL, type: String, size: Int64, name: String)
    }

    let status: Int
    let body: Body

    static let jsonType = "application/json"
    static let htmlType = "text/html; charset=utf-8"

    static func status(_ code: Int) -> HTTPResponse {
        HTTPResponse(status: code, body: .empty)
    }

    static func json(_ value: some Encodable) -> HTTPResponse {
        do {
            return HTTPResponse(status: HTTPStatus.ok, body: .data(try JSONEncoder().encode(value), type: jsonType))
        } catch {
            Log.server.error("Response not encoded: \(error.localizedDescription)")
            return .status(HTTPStatus.serverError)
        }
    }

    /// Status line and headers; the connection closes after each answer.
    var head: Data {
        var lines = ["HTTP/1.1 \(status) \(Self.reason(for: status))", "Connection: close"]
        switch body {
        case .empty:
            lines.append("Content-Length: 0")
        case let .data(data, type):
            lines += ["Content-Type: \(type)", "Content-Length: \(data.count)"]
        case let .file(_, type, size, name):
            lines += ["Content-Type: \(type)", "Content-Length: \(size)",
                      "Content-Disposition: attachment; filename=\"\(name.replacingOccurrences(of: "\"", with: ""))\""]
        }
        return Data((lines.joined(separator: "\r\n") + "\r\n\r\n").utf8)
    }

    private static func reason(for status: Int) -> String {
        switch status {
        case HTTPStatus.ok: "OK"
        case HTTPStatus.noContent: "No Content"
        case HTTPStatus.badRequest: "Bad Request"
        case HTTPStatus.unauthorized: "Unauthorized"
        case HTTPStatus.forbidden: "Forbidden"
        case HTTPStatus.notFound: "Not Found"
        case HTTPStatus.conflict: "Conflict"
        default: "Error"
        }
    }
}

nonisolated extension HTTPStatus {
    static let badRequest = 400
    static let notFound = 404
    static let serverError = 500
}
