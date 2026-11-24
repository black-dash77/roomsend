import SwiftUI

/// What to send to one device: the device at the top, the four sources under the thumb.
struct DeviceSourceSheet: View {
    let device: NearbyDevice
    let isPasteAvailable: Bool
    let onPick: (ContentSource) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        VStack(spacing: Space.xl) {
            VStack(spacing: Space.sm) {
                IdentityAvatar(fingerprint: device.id, size: Size.recipientAvatar, deviceType: device.type)
                Text("room.sendTo \(device.alias)")
                    .textStyle(.title)
                    .foregroundStyle(Palette.textPrimary)
                    .multilineTextAlignment(.center)
            }
            Button { favorites.toggle(device) } label: {
                Label(favorites.contains(device.id) ? "room.unfavorite" : "room.makeFavorite",
                      systemImage: favorites.contains(device.id) ? "star.fill" : "star")
            }
            .buttonStyle(.secondaryPill)
            SourceTiles(isPasteAvailable: isPasteAvailable) { source in
                onPick(source)
                dismiss()
            }
        }
        .padding(.horizontal, Space.lg)
        .padding(.top, Space.xxl)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Palette.background.ignoresSafeArea())
        .presentationDetents([.height(Size.sourceSheetHeight)])
        .presentationDragIndicator(.visible)
    }
}
