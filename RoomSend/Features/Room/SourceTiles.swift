import SwiftUI

/// Where the things to send come from.
nonisolated enum ContentSource: CaseIterable, Identifiable, Sendable {
    case photos, files, text, paste

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .photos: "source.photos"
        case .files: "source.files"
        case .text: "source.text"
        case .paste: "source.paste"
        }
    }

    var symbolName: String {
        switch self {
        case .photos: "photo.on.rectangle.angled"
        case .files: "doc.fill"
        case .text: "text.bubble.fill"
        case .paste: "doc.on.clipboard.fill"
        }
    }
}

/// The four sources as tiles with their name inside, MetaMask's action row: large enough for
/// the thumb, and the name never far from the icon.
struct SourceTiles: View {
    let isPasteAvailable: Bool
    let onPick: (ContentSource) -> Void

    var body: some View {
        HStack(spacing: Space.sm) {
            ForEach(ContentSource.allCases) { source in
                Button { onPick(source) } label: { tile(for: source) }
                    .buttonStyle(TileButtonStyle())
                    .disabled(source == .paste && !isPasteAvailable)
            }
        }
    }

    private func tile(for source: ContentSource) -> some View {
        VStack(spacing: Space.sm) {
            Image(systemName: source.symbolName)
                .font(.system(size: Size.tileIcon, weight: .semibold))
            Text(source.title)
                .textStyle(.label)
                .lineLimit(1)
                .minimumScaleFactor(Tint.carouselMinScale)
        }
        .foregroundStyle(Palette.textPrimary)
        .frame(maxWidth: .infinity, minHeight: Size.tileHeight)
        .background(Palette.block, in: RoundedRectangle(cornerRadius: Radius.tile, style: .continuous))
    }
}

private struct TileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        TileBody(label: configuration.label, isPressed: configuration.isPressed)
    }
}

private struct TileBody<Label: View>: View {
    let label: Label
    let isPressed: Bool
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        label
            .opacity(isEnabled ? 1 : Tint.disabled)
            .scaleEffect(isPressed ? Tint.pressScale : 1)
            .animation(Motion.quick, value: isPressed)
    }
}
