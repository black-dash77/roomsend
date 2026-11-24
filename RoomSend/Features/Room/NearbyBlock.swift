import SwiftUI

/// The devices of the room, one row each. Touching a row asks what to send to that device.
struct NearbyBlock: View {
    let devices: [NearbyDevice]
    let favorites: Set<NearbyDevice.ID>
    let onSelect: (NearbyDevice) -> Void

    var body: some View {
        Block(label: "room.nearby.title") {
            if devices.isEmpty {
                BlockRow(
                    title: Text("room.nearby.empty.title"),
                    detail: Text("room.nearby.empty.detail"),
                    leading: { IconRound(systemName: "wifi") },
                    trailing: { EmptyView() }
                )
            } else if devices.count > Overlap.maxRows {
                ScrollView { rows }
                    .scrollIndicators(.hidden)
            } else {
                rows
            }
        }
    }

    /// The rows at their own height: the block is as tall as the room, and only scrolls once
    /// the room no longer fits on the screen.
    private var rows: some View {
        VStack(spacing: Space.md) {
            ForEach(devices) { device in
                Button { onSelect(device) } label: { DeviceRow(device: device, isFavorite: favorites.contains(device.id)) }
                    .buttonStyle(.plain)
                    .transition(.scale(scale: Motion.entranceScale).combined(with: .opacity))
            }
        }
    }
}

/// A device: its avatar with the type badge, its alias, its model and whether it encrypts.
struct DeviceRow: View {
    let device: NearbyDevice
    var isFavorite = false

    var body: some View {
        BlockRow(
            title: Text(verbatim: device.alias),
            detail: detail,
            leading: { IdentityAvatar(fingerprint: device.id, size: Size.rowAvatar, deviceType: device.type) },
            trailing: {
                HStack(spacing: Space.sm) {
                    if isFavorite { Image(systemName: "star.fill").foregroundStyle(Palette.live).accessibilityLabel(Text("room.favorite")) }
                    Image(systemName: "chevron.right").foregroundStyle(Palette.textMuted)
                }
            }
        )
    }

    private var detail: Text {
        let model = device.info.deviceModel ?? device.type?.rawValue.capitalized ?? ""
        return device.transport == .https ? Text("room.device.secure \(model)") : Text("room.device.open \(model)")
    }
}
