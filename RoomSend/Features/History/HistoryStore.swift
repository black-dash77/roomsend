import Foundation
import Observation
import OSLog

/// A transfer that ended well, in one direction or the other.
nonisolated struct TransferRecord: Codable, Identifiable, Equatable, Sendable {
    enum Direction: String, Codable, Sendable {
        case sent, received
    }

    let id: UUID
    let direction: Direction
    let peerAlias: String
    let peerFingerprint: String
    let peerType: DeviceType?
    let photoCount: Int
    let fileCount: Int
    let textCount: Int
    let byteCount: Int64
    let date: Date
}

/// The transfers of this device, newest first, kept between launches.
@Observable
final class HistoryStore {
    private(set) var records: [TransferRecord]

    private let defaults: UserDefaults
    private static let storageKey = "history.v2"
    private static let maxRecords = 200

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        records = Self.load(from: defaults)
    }

    func record(_ items: [OutgoingItem], to device: NearbyDevice) {
        let summary = SendSummary(items: items)
        insert(TransferRecord(
            id: UUID(), direction: .sent, peerAlias: device.alias, peerFingerprint: device.id, peerType: device.type,
            photoCount: summary.photoCount, fileCount: summary.fileCount, textCount: summary.textCount,
            byteCount: summary.byteCount, date: .now
        ))
    }

    func record(received offer: IncomingOffer) {
        let isMessage = offer.message != nil
        let summary = offer.summary
        insert(TransferRecord(
            id: UUID(), direction: .received, peerAlias: offer.sender.alias, peerFingerprint: offer.sender.fingerprint,
            peerType: offer.sender.deviceType.flatMap(DeviceType.init(rawValue:)),
            photoCount: isMessage ? 0 : summary.photoCount, fileCount: isMessage ? 0 : summary.fileCount,
            textCount: isMessage ? offer.files.count : 0, byteCount: summary.byteCount, date: .now
        ))
    }

    private func insert(_ record: TransferRecord) {
        records = Array(([record] + records).prefix(Self.maxRecords))
        do {
            defaults.set(try JSONEncoder().encode(records), forKey: Self.storageKey)
        } catch {
            Log.history.error("History not saved: \(error.localizedDescription)")
        }
    }

    private static func load(from defaults: UserDefaults) -> [TransferRecord] {
        guard let data = defaults.data(forKey: storageKey) else { return [] }
        do {
            return try JSONDecoder().decode([TransferRecord].self, from: data)
        } catch {
            Log.history.error("History unreadable, starting empty: \(error.localizedDescription)")
            return []
        }
    }
}
