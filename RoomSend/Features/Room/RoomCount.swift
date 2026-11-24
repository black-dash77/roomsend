import SwiftUI

/// The one big figure of the room: how many devices are around, alone on its line, the words
/// under it, the way Revolut sets a balance. Above it, the avatars of those devices.
struct RoomCount: View {
    let devices: [NearbyDevice]
    /// Read so the phrase is built again in the new language when the person picks one.
    @Environment(\.locale) private var locale
    let state: DiscoveryService.State
    let isVisible: Bool

    var body: some View {
        VStack(spacing: Space.lg) {
            AvatarStack(devices: devices)
            VStack(spacing: Space.xxs) {
                Text(devices.count, format: .number)
                    .textStyle(.hero)
                    .foregroundStyle(Palette.textPrimary)
                    .contentTransition(.numericText(value: Double(devices.count)))
                Text(verbatim: unitWords)
                    .textStyle(.heroUnit)
                    .foregroundStyle(Palette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(Tint.carouselMinScale)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: phrase))
            status
        }
        .animation(Motion.settle, value: devices.count)
    }

    private var status: some View {
        HStack(spacing: Space.sm) {
            Circle()
                .fill(isLive ? Palette.live : Palette.textMuted)
                .frame(width: Size.liveDot, height: Size.liveDot)
            Text(statusKey)
                .textStyle(.meta)
                .foregroundStyle(Palette.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    /// « 2 appareils autour », one localized phrase so each language keeps its plural rules.
    private var phrase: String {
        Localized.string("room.count \(devices.count)", locale: locale)
    }

    /// The phrase without its figure (« appareils autour »), set under the figure.
    private var unitWords: String {
        phrase
            .replacingOccurrences(of: devices.count.formatted(.number.locale(locale)), with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    private var isLive: Bool { state == .listening && isVisible }

    private var statusKey: LocalizedStringKey {
        switch (state, isVisible) {
        case (.failed, _): "room.status.failed"
        case (_, false): "room.status.hidden"
        case (.listening, true): "room.status.listening"
        case (.idle, true): "room.status.starting"
        }
    }
}

/// The devices of the room as overlapping avatars; a slow dashed ring while nobody is there.
private struct AvatarStack: View {
    let devices: [NearbyDevice]

    var body: some View {
        if devices.isEmpty {
            ListeningRing()
        } else {
            HStack(spacing: -Size.stackAvatar * Overlap.stack) {
                ForEach(devices.prefix(Overlap.maxVisible)) { device in
                    IdentityAvatar(fingerprint: device.id, size: Size.stackAvatar)
                        .overlay { Circle().stroke(Palette.background, lineWidth: Size.avatarRing) }
                        .transition(.scale(scale: Motion.entranceScale).combined(with: .opacity))
                }
                if devices.count > Overlap.maxVisible { overflow }
            }
            .frame(height: Size.stackAvatar)
        }
    }

    private var overflow: some View {
        Text(verbatim: "+\(devices.count - Overlap.maxVisible)")
            .textStyle(.rowTitle)
            .foregroundStyle(Palette.textPrimary)
            .frame(width: Size.stackAvatar, height: Size.stackAvatar)
            .background(Palette.inset, in: Circle())
            .overlay { Circle().stroke(Palette.background, lineWidth: Size.avatarRing) }
    }
}

private struct ListeningRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isBreathing = false

    var body: some View {
        Circle()
            .stroke(Palette.textMuted, style: StrokeStyle(lineWidth: Size.listeningRing, dash: Size.listeningDash))
            .frame(width: Size.stackAvatar, height: Size.stackAvatar)
            .scaleEffect(isBreathing ? 1 : Motion.entranceScale)
            .opacity(isBreathing ? 1 : Tint.carouselMinOpacity)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: Motion.pulsePeriod / 2).repeatForever()) { isBreathing = true }
            }
            .accessibilityHidden(true)
    }
}
