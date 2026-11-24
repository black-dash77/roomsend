import Foundation
import Observation
import OSLog

/// The devices starred by the person, by fingerprint, with where they were last reached so a
/// favorite can be asked again even when multicast is silent.
@Observable
final class FavoritesStore {
    private(set) var favorites: [String: NearbyDevice.Saved] = [:]

    private let defaults: UserDefaults
    private static let storageKey = "favorites"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey) {
            do {
                favorites = try JSONDecoder().decode([String: NearbyDevice.Saved].self, from: data)
            } catch {
                Log.discovery.error("Favorites unreadable, starting empty: \(error.localizedDescription)")
            }
        }
    }

    func contains(_ id: NearbyDevice.ID) -> Bool { favorites[id] != nil }

    func toggle(_ device: NearbyDevice) {
        favorites[device.id] = contains(device.id) ? nil : NearbyDevice.Saved(device: device)
        save()
    }

    /// Favorites first, then the others, each group by name.
    func ordered(_ devices: [NearbyDevice]) -> [NearbyDevice] {
        devices.sorted { lhs, rhs in
            let left = contains(lhs.id), right = contains(rhs.id)
            if left != right { return left }
            return lhs.alias.localizedStandardCompare(rhs.alias) == .orderedAscending
        }
    }

    private func save() {
        do {
            defaults.set(try JSONEncoder().encode(favorites), forKey: Self.storageKey)
        } catch {
            Log.discovery.error("Favorites not saved: \(error.localizedDescription)")
        }
    }
}

extension NearbyDevice {
    /// What is kept of a favorite between launches.
    nonisolated struct Saved: Codable, Equatable, Sendable {
        let info: DeviceInfo
        let host: String

        init(device: NearbyDevice) {
            info = device.info
            host = device.host
        }

        var device: NearbyDevice { NearbyDevice(info: info, host: host) }
    }
}
