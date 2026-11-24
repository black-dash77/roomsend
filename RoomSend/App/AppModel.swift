import Foundation
import Observation

/// Builds the app's models once and starts or stops what listens on the network.
@Observable
final class AppModel {
    let identity: IdentityStore
    let network: NetworkSettings
    let discovery: DiscoveryService
    let history: HistoryStore
    let flow: SendFlow
    let receiveSettings: ReceiveSettings
    let receiver: ReceiveCoordinator
    let server: HTTPServer
    let favorites: FavoritesStore
    let shareLink: ShareLink
    let language: LanguageSettings

    private let tlsIdentity: TLSIdentity?

    init() {
        tlsIdentity = TLSIdentityStore.loadOrCreate()
        identity = IdentityStore(certificateFingerprint: tlsIdentity?.fingerprint)
        network = NetworkSettings()
        discovery = DiscoveryService(identity: identity, network: network)
        history = HistoryStore()
        flow = SendFlow()
        receiveSettings = ReceiveSettings()
        receiver = ReceiveCoordinator(settings: receiveSettings, history: history)
        server = HTTPServer()
        favorites = FavoritesStore()
        shareLink = ShareLink()
        language = LanguageSettings()
    }

    /// HTTPS needs the certificate; without it the server falls back to plain HTTP.
    var canEncrypt: Bool { tlsIdentity != nil }

    func goOnline() {
        if !canEncrypt { network.isEncrypted = false }
        let identity = self.identity, network = self.network
        let router = LocalSendRouter(receiver: receiver, discovery: discovery) {
            identity.info(network: network, announce: nil)
        }
        server.start(port: network.port, identity: network.isEncrypted ? tlsIdentity : nil, handler: router)
        discovery.start()
    }

    func goOffline() {
        discovery.stop()
        server.stop()
        shareLink.stop()
    }

    /// What the share extension left: offered for sending as soon as the app is in front.
    func openSharedItems() {
        let urls = Inbox.takeAll()
        guard !urls.isEmpty else { return }
        var items = ItemLoader.items(from: urls.filter { $0.lastPathComponent != Inbox.textFileName })
        if let textURL = urls.first(where: { $0.lastPathComponent == Inbox.textFileName }),
           let text = try? String(contentsOf: textURL, encoding: .utf8),
           let item = ItemLoader.item(fromText: text) {
            items.append(item)
        }
        Inbox.clear()
        flow.begin(with: items, recipient: nil, among: discovery.devices)
    }

    /// After a change of port or encryption: the others must hear the new address.
    func restartNetwork() {
        goOffline()
        goOnline()
    }
}
