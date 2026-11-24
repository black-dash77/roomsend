import Foundation
import Network
import Observation
import OSLog

/// Finds the LocalSend devices of the Wi-Fi (protocol v2.2, section 3): announces this device by
/// multicast UDP, listens to the others, answers them by `POST /register` (multicast as fallback),
/// takes the registrations they send, and asks every address of the network when multicast is
/// silent or refused.
@Observable
final class DiscoveryService {
    enum State: Equatable {
        case idle, listening, failed
    }

    private(set) var devices: [NearbyDevice] = []
    private(set) var state: State = .idle
    private(set) var isScanning = false
    var isVisible = true {
        didSet { if isVisible { announce() } }
    }

    private let identity: IdentityStore
    private let network: NetworkSettings
    private var group: NWConnectionGroup?

    private static let scanDelay: Duration = .seconds(3)

    init(identity: IdentityStore, network: NetworkSettings) {
        self.identity = identity
        self.network = network
    }

    func start() {
        guard group == nil else { return announce() }
        do {
            let group = try makeGroup()
            self.group = group
            group.start(queue: .main)
        } catch {
            Log.discovery.error("Multicast group refused: \(error.localizedDescription)")
            state = .failed
            scan()
        }
        Task {
            try? await Task.sleep(for: Self.scanDelay)
            if devices.isEmpty { scan() }
        }
    }

    func stop() {
        group?.cancel()
        group = nil
        state = .idle
    }

    /// Forgets who was heard and asks the room again, address by address too.
    func refresh() {
        devices.removeAll()
        announce()
        scan()
    }

    /// A device that registered itself with our server.
    func register(_ info: DeviceInfo, host: String) {
        guard info.fingerprint != identity.identity.fingerprint else { return }
        upsert(NearbyDevice(info: info, host: host))
    }

    /// Asks one address directly, for a device added by hand; keeps it when it answers.
    func probe(_ address: ManualAddress) async -> NearbyDevice? {
        let client = RegisterClient(sender: localInfo(announce: nil))
        for transport in [TransportProtocol.https, .http] {
            if let device = await client.scan(hosts: [address.host], port: address.port, transport: transport).first {
                upsert(device)
                return device
            }
        }
        return nil
    }

    /// Favorites seen before: asked again directly, so they show up even without multicast.
    func recall(_ saved: [NearbyDevice.Saved]) {
        let client = RegisterClient(sender: localInfo(announce: nil))
        Task {
            for favorite in saved where !devices.contains(where: { $0.id == favorite.info.fingerprint }) {
                let port = favorite.info.port ?? Int(LocalSendProtocol.port)
                let found = await client.scan(hosts: [favorite.host], port: port, transport: favorite.info.protocol ?? .https)
                found.forEach(upsert)
            }
        }
    }

    /// Asks every address of the /24 for its LocalSend identity (protocol section 3.2).
    func scan() {
        guard network.isFallbackScanEnabled, !isScanning else { return }
        isScanning = true
        let client = RegisterClient(sender: localInfo(announce: nil))
        let port = Int(network.port), transport = network.transport
        Task {
            let found = await client.scan(hosts: LocalAddress.neighbours(), port: port, transport: transport)
            found.forEach(upsert)
            isScanning = false
        }
    }

    private func localInfo(announce: Bool?) -> DeviceInfo {
        identity.info(network: network, announce: announce)
    }

    private func makeGroup() throws -> NWConnectionGroup {
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(LocalSendProtocol.multicastHost),
            port: NWEndpoint.Port(rawValue: LocalSendProtocol.port) ?? .any
        )
        let parameters = NWParameters.udp
        parameters.allowLocalEndpointReuse = true
        let group = NWConnectionGroup(with: try NWMulticastGroup(for: [endpoint]), using: parameters)
        group.setReceiveHandler(maximumMessageSize: LocalSendProtocol.maxDatagramSize) { [weak self] message, content, _ in
            MainActor.assumeIsolated { self?.receive(content, from: message.remoteEndpoint) }
        }
        group.stateUpdateHandler = { [weak self] newState in
            MainActor.assumeIsolated { self?.update(to: newState) }
        }
        return group
    }

    private func update(to newState: NWConnectionGroup.State) {
        switch newState {
        case .ready:
            state = .listening
            announce()
        case let .failed(error):
            Log.discovery.error("Multicast group failed: \(error.localizedDescription)")
            state = .failed
            scan()
        default:
            break
        }
    }

    private func receive(_ content: Data?, from endpoint: NWEndpoint?) {
        guard let content, let host = endpoint?.hostString else { return }
        let info: DeviceInfo
        do {
            info = try JSONDecoder().decode(DeviceInfo.self, from: content)
        } catch {
            Log.discovery.debug("Ignored a datagram that is not LocalSend: \(error.localizedDescription)")
            return
        }
        guard info.fingerprint != identity.identity.fingerprint else { return }
        let device = NearbyDevice(info: info, host: host)
        upsert(device)
        if info.announce == true, isVisible { answer(device) }
    }

    /// Answers by HTTP, as the protocol prefers; by multicast if the device cannot be reached.
    private func answer(_ device: NearbyDevice) {
        let client = RegisterClient(sender: localInfo(announce: nil))
        Task {
            if await client.answer(device) { return }
            send(localInfo(announce: false))
        }
    }

    private func upsert(_ device: NearbyDevice) {
        if let index = devices.firstIndex(where: { $0.id == device.id }) {
            devices[index] = device
        } else {
            devices.append(device)
        }
    }

    private func announce() {
        guard isVisible else { return }
        send(localInfo(announce: true))
    }

    private func send(_ info: DeviceInfo) {
        guard let group, state == .listening else { return }
        do {
            group.send(content: try JSONEncoder().encode(info)) { error in
                if let error { Log.discovery.error("Announcement not sent: \(error.localizedDescription)") }
            }
        } catch {
            Log.discovery.error("Announcement not encoded: \(error.localizedDescription)")
        }
    }
}
