import SwiftUI

/// The top line: who you are on the Wi-Fi (touch it for a new name), and « look again ».
struct RoomHeader: View {
    let identity: DeviceIdentity
    let onShuffle: () -> Void
    let onRefresh: () -> Void
    let onAdd: () -> Void

    var body: some View {
        HStack {
            Button(action: onShuffle) { identityChip }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("room.identity.shuffle"))
                .accessibilityValue(Text(verbatim: identity.alias))
            Spacer()
            roundButton("plus", label: "room.add", action: onAdd)
            roundButton("arrow.clockwise", label: "room.refresh", action: onRefresh)
        }
    }

    private func roundButton(_ symbol: String, label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: Size.rowIcon, weight: .semibold))
                .foregroundStyle(Palette.textPrimary)
                .frame(width: Size.touch, height: Size.touch)
        }
        .glassEffect(.regular.interactive(), in: Circle())
        .accessibilityLabel(Text(label))
    }

    private var identityChip: some View {
        HStack(spacing: Space.sm) {
            IdentityAvatar(fingerprint: identity.fingerprint, size: Size.identityChip)
            Text(verbatim: identity.alias)
                .textStyle(.rowTitle)
                .foregroundStyle(Palette.textPrimary)
                .contentTransition(.interpolate)
            Image(systemName: "shuffle")
                .font(.system(size: Size.badgeIcon, weight: .bold))
                .foregroundStyle(Palette.textMuted)
        }
        .padding(.vertical, Space.xs)
        .padding(.leading, Space.xs)
        .padding(.trailing, Space.md)
        .background(Palette.block, in: Capsule())
    }
}
