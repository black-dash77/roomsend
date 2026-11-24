import SwiftUI
import UIKit

/// The room: who is around, what to send, and to whom. One screen, no scrolling; only the
/// device list scrolls inside its block when the room is full.
struct RoomScreen: View {
    @Environment(IdentityStore.self) private var identity
    @Environment(DiscoveryService.self) private var discovery
    @Environment(SendFlow.self) private var flow
    @Environment(FavoritesStore.self) private var favorites
    @Environment(\.scenePhase) private var scenePhase

    @State private var source: ContentSource?
    @State private var pendingRecipient: NearbyDevice.ID?
    @State private var pendingSource: ContentSource?
    @State private var selectedDevice: NearbyDevice?
    @State private var isAddingDevice = false
    @State private var isPasteAvailable = UIPasteboard.general.hasStrings

    var body: some View {
        VStack(spacing: Space.xxl) {
            RoomHeader(
                identity: identity.identity,
                onShuffle: { withAnimation(Motion.settle) { identity.shuffleAlias() } },
                onRefresh: refreshRoom,
                onAdd: { isAddingDevice = true }
            )
            RoomCount(devices: discovery.devices, state: discovery.state, isVisible: discovery.isVisible)
                .padding(.top, Space.lg)
            SourceTiles(isPasteAvailable: isPasteAvailable) { pick($0, for: nil) }
            NearbyBlock(devices: favorites.ordered(discovery.devices), favorites: Set(favorites.favorites.keys)) { selectedDevice = $0 }
            Spacer(minLength: 0)
        }
        .sheet(isPresented: $isAddingDevice) { AddDeviceSheet() }
        .onAppear(perform: recallFavorites)
        .sheet(item: $selectedDevice, onDismiss: openPendingSource) { device in
            DeviceSourceSheet(device: device, isPasteAvailable: isPasteAvailable) { chosen in
                pendingSource = chosen
                pendingRecipient = device.id
            }
        }
        .padding(.horizontal, Space.lg)
        .padding(.top, Space.sm)
        .background(Palette.background.ignoresSafeArea())
        .animation(Motion.settle, value: discovery.devices)
        .contentPickers(source: $source) { items in
            flow.begin(with: items, recipient: pendingRecipient, among: discovery.devices)
            pendingRecipient = nil
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { isPasteAvailable = UIPasteboard.general.hasStrings }
        }
    }

    /// A new look around. Favorites are asked again directly: one added by its address answers
    /// neither the multicast nor the scan, and would otherwise vanish from the room.
    private func refreshRoom() {
        withAnimation(Motion.settle) { discovery.refresh() }
        recallFavorites()
    }

    private func recallFavorites() {
        discovery.recall(Array(favorites.favorites.values))
    }

    private func pick(_ newSource: ContentSource, for recipient: NearbyDevice.ID?) {
        pendingRecipient = recipient
        source = newSource
    }

    /// A source chosen in a device's sheet opens once that sheet is gone: two presentations
    /// cannot overlap.
    private func openPendingSource() {
        guard let pendingSource else { return }
        self.pendingSource = nil
        source = pendingSource
    }
}
