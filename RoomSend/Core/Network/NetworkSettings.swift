import Foundation
import Observation

/// How this device shows itself on the Wi-Fi: its port, whether it encrypts, whether it also
/// looks for devices address by address when multicast stays silent.
@Observable
final class NetworkSettings {
    var port: UInt16 {
        didSet { defaults.set(Int(port), forKey: Keys.port) }
    }
    var isEncrypted: Bool {
        didSet { defaults.set(isEncrypted, forKey: Keys.encrypted) }
    }
    var isFallbackScanEnabled: Bool {
        didSet { defaults.set(isFallbackScanEnabled, forKey: Keys.fallbackScan) }
    }

    var transport: TransportProtocol { isEncrypted ? .https : .http }

    private let defaults: UserDefaults

    private enum Keys {
        static let port = "network.port"
        static let encrypted = "network.encrypted"
        static let fallbackScan = "network.fallbackScan"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let storedPort = defaults.integer(forKey: Keys.port)
        port = UInt16(exactly: storedPort).flatMap { $0 == 0 ? nil : $0 } ?? LocalSendProtocol.port
        isEncrypted = defaults.object(forKey: Keys.encrypted) as? Bool ?? true
        isFallbackScanEnabled = defaults.object(forKey: Keys.fallbackScan) as? Bool ?? true
    }

    func resetPort() {
        port = LocalSendProtocol.port
    }
}
