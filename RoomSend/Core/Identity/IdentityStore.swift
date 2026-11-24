import Foundation
import Observation
import OSLog
import UIKit

/// This device's identity, created once and kept between launches.
@Observable
final class IdentityStore {
    private(set) var identity: DeviceIdentity

    private let defaults: UserDefaults
    private static let storageKey = "identity"
    private static let fingerprintByteCount = 32

    /// `certificateFingerprint` is the hash of this device's TLS certificate, when there is one.
    init(certificateFingerprint: String?, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        identity = Self.load(from: defaults) ?? Self.makeIdentity()
        if let certificateFingerprint { identity.fingerprint = certificateFingerprint }
        save()
    }

    /// Draws a new alias; the fingerprint, and so the avatar, stays.
    func shuffleAlias() {
        var alias = Self.randomAlias()
        while alias == identity.alias { alias = Self.randomAlias() }
        identity.alias = alias
        save()
    }

    /// A name typed by the person; an empty one is ignored.
    func rename(_ alias: String) {
        let trimmed = alias.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != identity.alias else { return }
        identity.alias = String(trimmed.prefix(Self.maxAliasLength))
        save()
    }

    func info(network: NetworkSettings, announce: Bool?) -> DeviceInfo {
        DeviceInfo(identity: identity, transport: network.transport, port: network.port, announce: announce)
    }

    private static let maxAliasLength = 40

    private func save() {
        do {
            defaults.set(try JSONEncoder().encode(identity), forKey: Self.storageKey)
        } catch {
            Log.identity.error("Could not save the identity: \(error.localizedDescription)")
        }
    }

    private static func load(from defaults: UserDefaults) -> DeviceIdentity? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        do {
            return try JSONDecoder().decode(DeviceIdentity.self, from: data)
        } catch {
            Log.identity.error("Saved identity unreadable, a new one is made: \(error.localizedDescription)")
            return nil
        }
    }

    private static func makeIdentity() -> DeviceIdentity {
        DeviceIdentity(
            alias: randomAlias(),
            fingerprint: randomFingerprint(),
            deviceModel: UIDevice.current.model,
            deviceType: .mobile
        )
    }

    private static func randomAlias() -> String {
        AliasGenerator.make()
    }

    private static func randomFingerprint() -> String {
        (0..<fingerprintByteCount)
            .map { _ in String(format: "%02x", UInt8.random(in: .min ... .max)) }
            .joined()
    }
}
