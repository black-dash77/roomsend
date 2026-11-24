import SwiftUI

/// Who receives: the devices of the room side by side, the one in the center is the choice
/// (app vivante, rule 4). With two devices or more, « The whole room » comes first.
struct RecipientCarousel: View {
    let devices: [NearbyDevice]
    @Binding var selection: NearbyDevice.ID?

    private var ids: [String] {
        (devices.count > 1 ? [SendFlow.everyoneID] : []) + devices.map(\.id)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: Space.sm) {
                        ForEach(ids, id: \.self) { id in
                            item(for: id).onTapGesture { center(on: id, with: proxy, animated: true) }
                        }
                    }
                    .scrollTargetLayout()
                }
                .safeAreaPadding(.horizontal, max((geometry.size.width - Size.recipientWidth) / 2, 0))
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $selection, anchor: .center)
                .scrollIndicators(.hidden)
                .mask(edgeFade)
                // The side margins depend on the width: the chosen device is centered again each
                // time it changes, so a row's choice always shows.
                .onChange(of: geometry.size.width, initial: true) { centerAfterLayout(on: selection, with: proxy) }
                // A choice made for the person (the first device found after the sheet opened)
                // is brought to the center too.
                .onChange(of: selection) { previous, chosen in
                    if previous == nil { centerAfterLayout(on: chosen, with: proxy) }
                }
            }
        }
        .frame(height: Size.carouselHeight)
    }

    /// A scroll asked for before the items have their frames is ignored: this one waits for the
    /// layout under way to finish.
    private func centerAfterLayout(on id: String?, with proxy: ScrollViewProxy) {
        Task { center(on: id, with: proxy, animated: false) }
    }

    private func center(on id: String?, with proxy: ScrollViewProxy, animated: Bool) {
        guard let id else { return }
        withAnimation(animated ? Motion.settle : nil) {
            selection = id
            proxy.scrollTo(id, anchor: .center)
        }
    }

    private func item(for id: String) -> some View {
        let isSelected = id == selection
        let device = devices.first { $0.id == id }
        return VStack(spacing: Space.sm) {
            if let device {
                IdentityAvatar(fingerprint: device.id, size: Size.recipientAvatar, deviceType: device.type)
            } else {
                RoomGlyph(devices: devices)
            }
            label(device.map { Text(verbatim: $0.alias) } ?? Text("send.everyone"), isSelected: isSelected)
        }
        .frame(width: Size.recipientWidth)
        .visualEffect { content, proxy in
            let progress = Self.distanceToCenter(proxy)
            let scale: CGFloat = 1 - (1 - Tint.carouselMinScale) * progress
            let opacity: Double = 1 - (1 - Tint.carouselMinOpacity) * Double(progress)
            return content.scaleEffect(scale).opacity(opacity)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private func label(_ text: Text, isSelected: Bool) -> some View {
        text
            .textStyle(.label)
            .foregroundStyle(isSelected ? Palette.textPrimary : Palette.textSecondary)
            .lineLimit(1)
    }

    /// 0 at the center of the carousel, 1 one item away or further.
    nonisolated private static func distanceToCenter(_ proxy: GeometryProxy) -> CGFloat {
        guard let bounds = proxy.bounds(of: .scrollView) else { return 0 }
        let frame = proxy.frame(in: .scrollView)
        return min(abs(frame.midX - bounds.midX) / Size.recipientWidth, 1)
    }

    private var edgeFade: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: Tint.edgeFade),
                .init(color: .black, location: 1 - Tint.edgeFade),
                .init(color: .clear, location: 1),
            ],
            startPoint: .leading, endPoint: .trailing
        )
    }
}

/// The whole room: the first avatars of the room gathered in one round.
private struct RoomGlyph: View {
    let devices: [NearbyDevice]

    private static let shown = 3

    var body: some View {
        ZStack {
            Circle().fill(Palette.inset)
            HStack(spacing: -Size.badge) {
                ForEach(devices.prefix(Self.shown)) { device in
                    IdentityAvatar(fingerprint: device.id, size: Size.identityChip)
                        .overlay { Circle().stroke(Palette.inset, lineWidth: Size.avatarRing) }
                }
            }
        }
        .frame(width: Size.recipientAvatar, height: Size.recipientAvatar)
    }
}
