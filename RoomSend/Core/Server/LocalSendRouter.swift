import Foundation
import OSLog

/// The LocalSend API this device answers (protocol v2.2, sections 3.2, 4 and 6.1). Runs off the
/// main actor and asks the main-actor models.
nonisolated final class LocalSendRouter: HTTPHandler {
    private let receiver: ReceiveCoordinator
    private let discovery: DiscoveryService
    private let localInfo: @MainActor @Sendable () -> DeviceInfo

    private static let maxJSONSize: Int64 = 1024 * 1024

    init(
        receiver: ReceiveCoordinator, discovery: DiscoveryService,
        localInfo: @escaping @MainActor @Sendable () -> DeviceInfo
    ) {
        self.receiver = receiver
        self.discovery = discovery
        self.localInfo = localInfo
    }

    func handle(_ request: HTTPRequestHead, body: HTTPBody, from host: String?) async -> HTTPResponse {
        let api = LocalSendProtocol.apiPath
        switch (request.method, request.path) {
        case ("POST", "\(api)/register"): return await register(body, from: host)
        case ("GET", "\(api)/info"), ("POST", "\(api)/info"): return .json(await localInfo())
        case ("POST", "\(api)/prepare-upload"): return await prepareUpload(request, body)
        case ("POST", "\(api)/upload"): return await upload(request, body)
        case ("POST", "\(api)/cancel"):
            await receiver.cancel(session: request.query["sessionId"] ?? "")
            return .status(HTTPStatus.ok)
        default: return .status(HTTPStatus.notFound)
        }
    }

    private func register(_ body: HTTPBody, from host: String?) async -> HTTPResponse {
        guard let info: DeviceInfo = await decode(body), let host else { return .status(HTTPStatus.badRequest) }
        await discovery.register(info, host: host)
        return .json(await localInfo())
    }

    private func prepareUpload(_ request: HTTPRequestHead, _ body: HTTPBody) async -> HTTPResponse {
        guard let offer: IncomingPrepareUpload = await decode(body) else { return .status(HTTPStatus.badRequest) }
        switch await receiver.prepare(offer, pin: request.query["pin"]) {
        case let .accepted(sessionID, tokens): return .json(PrepareUploadResponse(sessionId: sessionID, files: tokens))
        case .nothingToTransfer: return .status(HTTPStatus.noContent)
        case .pinRequired: return .status(HTTPStatus.unauthorized)
        case .rejected: return .status(HTTPStatus.forbidden)
        case .busy: return .status(HTTPStatus.conflict)
        }
    }

    private func upload(_ request: HTTPRequestHead, _ body: HTTPBody) async -> HTTPResponse {
        let session = request.query["sessionId"] ?? "", file = request.query["fileId"] ?? ""
        guard let url = await receiver.destination(session: session, file: file, token: request.query["token"] ?? "") else {
            return .status(HTTPStatus.forbidden)
        }
        do {
            try await body.write(to: url)
        } catch {
            Log.receive.error("Upload of \(file) interrupted: \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: url)
            return .status(HTTPStatus.serverError)
        }
        await receiver.didReceive(session: session, file: file)
        return .status(HTTPStatus.ok)
    }

    private func decode<T: Decodable>(_ body: HTTPBody) async -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: try await body.data(limit: Self.maxJSONSize))
        } catch {
            Log.server.error("Request body unreadable: \(error.localizedDescription)")
            return nil
        }
    }
}
