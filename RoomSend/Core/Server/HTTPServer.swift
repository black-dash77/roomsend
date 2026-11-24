import Foundation
import Network
import Observation
import OSLog

/// Listens for LocalSend requests on the chosen port (or any free one), over TLS when an identity
/// is given.
@Observable
final class HTTPServer {
    enum State: Equatable {
        case stopped, listening, failed
    }

    private(set) var state: State = .stopped
    /// The port actually listened on, known once the listener is ready.
    private(set) var port: UInt16?
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "app.roomsend.server")

    /// `port` nil lets the system pick a free one.
    func start(port: UInt16?, identity: TLSIdentity?, handler: some HTTPHandler) {
        stop()
        guard let endpointPort = port.map(NWEndpoint.Port.init(rawValue:)) ?? .any else { return }
        do {
            let listener = try NWListener(using: Self.parameters(identity: identity), on: endpointPort)
            let queue = self.queue
            listener.newConnectionHandler = { connection in
                HTTPConnection(connection).serve(on: queue, with: handler)
            }
            listener.stateUpdateHandler = { [weak self] newState in
                Task { @MainActor in self?.update(to: newState) }
            }
            listener.start(queue: queue)
            self.listener = listener
        } catch {
            Log.server.error("Listener refused on port \(endpointPort.rawValue): \(error.localizedDescription)")
            state = .failed
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
        port = nil
        state = .stopped
    }

    private func update(to newState: NWListener.State) {
        switch newState {
        case .ready:
            port = listener?.port?.rawValue
            state = .listening
        case let .failed(error):
            Log.server.error("Listener failed: \(error.localizedDescription)")
            state = .failed
        default:
            break
        }
    }

    nonisolated private static func parameters(identity: TLSIdentity?) -> NWParameters {
        let parameters: NWParameters
        if let identity, let secIdentity = sec_identity_create(identity.identity) {
            let tls = NWProtocolTLS.Options()
            sec_protocol_options_set_local_identity(tls.securityProtocolOptions, secIdentity)
            parameters = NWParameters(tls: tls, tcp: NWProtocolTCP.Options())
        } else {
            parameters = NWParameters(tls: nil, tcp: NWProtocolTCP.Options())
        }
        parameters.allowLocalEndpointReuse = true
        return parameters
    }
}

extension NWEndpoint {
    /// The address of a peer, without the interface suffix of a scoped IPv6 address.
    nonisolated var hostString: String? {
        guard case let .hostPort(host, _) = self else { return nil }
        let text: String
        switch host {
        case let .ipv4(address): text = "\(address)"
        case let .ipv6(address): text = "\(address)"
        case let .name(name, _): text = name
        @unknown default: return nil
        }
        return text.split(separator: "%").first.map(String.init)
    }
}
