import Foundation
import Observation

/// Shares picked items by link: a small page any browser of the Wi-Fi opens, with one download
/// per file. Served in plain HTTP, so no browser warns about a certificate, on a port the system
/// picks free, so it never collides with another server.
@Observable
final class ShareLink {
    enum Status: Equatable {
        case off, starting, ready(URL), noWiFi, failed
    }

    private(set) var items: [OutgoingItem] = []

    private let server = HTTPServer()
    private var address: String?
    private var isStarted = false

    /// The link is shown only once its server listens: an address that answers nothing never is.
    var status: Status {
        guard isStarted else { return .off }
        guard let address else { return .noWiFi }
        switch server.state {
        case .listening:
            guard let port = server.port, let url = URL(string: "http://\(address):\(port)/") else { return .failed }
            return .ready(url)
        case .failed: return .failed
        case .stopped: return .starting
        }
    }

    func start(_ items: [OutgoingItem], owner: String) {
        isStarted = true
        self.items = items
        address = LocalAddress.wifiIPv4()
        guard address != nil else { return }
        server.start(port: nil, identity: nil, handler: ShareLinkPage(items: items, owner: owner))
    }

    func stop() {
        server.stop()
        isStarted = false
        address = nil
        items = []
    }
}

/// The page and the downloads of a shared link.
nonisolated struct ShareLinkPage: HTTPHandler {
    let items: [OutgoingItem]
    let owner: String

    private static let filePrefix = "/f/"

    func handle(_ request: HTTPRequestHead, body: HTTPBody, from host: String?) async -> HTTPResponse {
        guard request.method == "GET" else { return .status(HTTPStatus.notFound) }
        if request.path == "/" { return HTTPResponse(status: HTTPStatus.ok, body: .data(Data(page.utf8), type: HTTPResponse.htmlType)) }
        guard request.path.hasPrefix(Self.filePrefix),
              let item = items.first(where: { $0.id == String(request.path.dropFirst(Self.filePrefix.count)) }) else {
            return .status(HTTPStatus.notFound)
        }
        return HTTPResponse(status: HTTPStatus.ok, body: .file(item.fileURL, type: item.fileType, size: item.size, name: item.fileName))
    }

    private var page: String {
        let rows = items.map { item in
            "<a class=\"row\" href=\"\(Self.filePrefix)\(item.id)\" download><span>\(Self.escape(item.fileName))</span>"
                + "<small>\(item.size.formatted(.byteCount(style: .file)))</small></a>"
        }.joined()
        let title = Self.escape(Localized.string("share.page.title \(owner)"))
        return """
        <!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>\(title)</title><style>\(Self.style)</style></head>
        <body><main><h1>\(title)</h1><p>\(Self.escape(Localized.string("share.page.detail")))</p>\(rows)</main></body></html>
        """
    }

    /// The 4.5 palette, light and dark, as on the app's blocks.
    private static let style = """
    :root{color-scheme:light dark;--bg:#F8F9FA;--block:#FFFFFF;--text:#09090B;--muted:#52525B}
    @media (prefers-color-scheme:dark){:root{--bg:#000000;--block:#0C0C0C;--text:#FAFAFA;--muted:#A1A1AA}}
    body{margin:0;background:var(--bg);color:var(--text);font:16px -apple-system,system-ui,sans-serif}
    main{max-width:560px;margin:0 auto;padding:48px 16px}
    h1{font-size:34px;font-stretch:condensed;font-weight:800;letter-spacing:-1px;margin:0 0 8px}
    p{color:var(--muted);margin:0 0 24px}
    .row{display:flex;justify-content:space-between;gap:12px;padding:16px;margin-bottom:8px;border-radius:18px;
    background:var(--block);color:var(--text);text-decoration:none;font-weight:600}
    small{color:var(--muted);font-weight:400}
    """

    private static func escape(_ text: String) -> String {
        text.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;").replacingOccurrences(of: "\"", with: "&quot;")
    }
}
