import Foundation
import Observation

/// One send, from the picked items to the last receiver's answer: to one device or to the whole
/// room, with the PIN when a receiver asks for one, stoppable at any time.
@Observable
final class SendFlow {
    enum Phase: Equatable {
        case reviewing
        case needsPin(alias: String, isRetry: Bool)
        case sending(alias: String, sent: Int64, total: Int64)
        /// `alias` is nil when the whole room received it.
        case sent(alias: String?)
        case failed(TransferError)
    }

    /// The carousel item that means « every device of the room ».
    static let everyoneID = "*"

    private(set) var items: [OutgoingItem] = []
    private(set) var phase: Phase = .reviewing
    var recipientID: NearbyDevice.ID?
    var pin = ""
    var isPresented = false

    private var task: Task<Void, Never>?
    private var current: (device: NearbyDevice, session: String)?
    /// Devices that already have everything: a send resumed after a PIN or a retry skips them.
    private var delivered: Set<NearbyDevice.ID> = []
    /// The device the typed PIN is for; another device asking for one starts from an empty field.
    private var pinOwner: NearbyDevice.ID?

    /// Opens the review with the picked items. The recipient chosen from a row is kept;
    /// otherwise the first device of the room is ready, so « Send » always works.
    func begin(with items: [OutgoingItem], recipient: NearbyDevice.ID?, among devices: [NearbyDevice]) {
        guard !items.isEmpty else { return }
        self.items = items
        recipientID = recipient ?? devices.first?.id
        pin = ""
        pinOwner = nil
        delivered = []
        phase = .reviewing
        isPresented = true
    }

    /// A review opened before anyone was found (from the share sheet, say) gets the first device
    /// that shows up, so « Send » works without a tap in the carousel.
    func pickDefaultRecipient(among devices: [NearbyDevice]) {
        guard recipientID == nil, case .reviewing = phase else { return }
        recipientID = devices.first?.id
    }

    func recipients(among devices: [NearbyDevice]) -> [NearbyDevice] {
        recipientID == Self.everyoneID ? devices : devices.filter { $0.id == recipientID }
    }

    func send(to devices: [NearbyDevice], sender: DeviceInfo, history: HistoryStore) {
        task = Task {
            for device in devices where !delivered.contains(device.id) {
                guard await send(to: device, sender: sender, history: history) else { return }
            }
            phase = .sent(alias: devices.count == 1 ? devices[0].alias : nil)
        }
    }

    /// Stops the transfer under way and tells its receiver.
    func cancel() {
        task?.cancel()
        if let current { Task { await TransferService.cancel(session: current.session, on: current.device) } }
        current = nil
        phase = .failed(.cancelled)
    }

    func retry() {
        phase = .reviewing
    }

    func close() {
        if case .sending = phase { cancel() }
        isPresented = false
        items = []
        recipientID = nil
        delivered = []
        phase = .reviewing
    }

    /// True when this device received everything; false stops a send to the whole room.
    private func send(to device: NearbyDevice, sender: DeviceInfo, history: HistoryStore) async -> Bool {
        let items = self.items, total = items.reduce(0) { $0 + $1.size }
        phase = .sending(alias: device.alias, sent: 0, total: total)
        let events = TransferService.Events(
            onSession: { session in await self.track(device, session: session) },
            onBytes: { sent in await self.progress(device.alias, sent: sent, total: total) }
        )
        do {
            try await TransferService(sender: sender).send(items, to: device, pin: pin, events: events)
            history.record(items, to: device)
            delivered.insert(device.id)
            current = nil
            return true
        } catch .pinRequired {
            askPin(for: device)
        } catch {
            if !Task.isCancelled { phase = .failed(error) }
        }
        current = nil
        return false
    }

    private func askPin(for device: NearbyDevice) {
        let isRetry = !pin.isEmpty && pinOwner == device.id
        if !isRetry { pin = "" }
        pinOwner = device.id
        phase = .needsPin(alias: device.alias, isRetry: isRetry)
    }

    private func track(_ device: NearbyDevice, session: String) {
        current = (device, session)
    }

    private func progress(_ alias: String, sent: Int64, total: Int64) {
        guard case .sending = phase else { return }
        phase = .sending(alias: alias, sent: min(sent, total), total: total)
    }
}
