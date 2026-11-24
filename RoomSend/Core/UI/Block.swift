import SwiftUI

/// A block of 4.5: one subject, its small label inside, opaque, without outline or glass.
struct Block<Content: View>: View {
    var label: LocalizedStringKey?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            if let label {
                Text(label)
                    .textStyle(.label)
                    .foregroundStyle(Palette.textSecondary)
            }
            content
        }
        .padding(Space.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.block, in: RoundedRectangle(cornerRadius: Radius.block, style: .continuous))
    }
}

/// A row of a block: a leading round, a title over a detail, an accessory on the right.
struct BlockRow<Leading: View, Trailing: View>: View {
    let title: Text
    var detail: Text?
    @ViewBuilder let leading: Leading
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: Space.md) {
            leading
            VStack(alignment: .leading, spacing: Space.xxs) {
                title
                    .textStyle(.rowTitle)
                    .foregroundStyle(Palette.textPrimary)
                    .lineLimit(1)
                detail?
                    .textStyle(.meta)
                    .foregroundStyle(Palette.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: Space.sm)
            trailing
        }
        .contentShape(Rectangle())
    }
}

/// A key on the left, its value on the right, as in Revolut's and MetaMask's reviews.
struct ValueRow: View {
    let key: Text
    let value: Text

    init(key: LocalizedStringKey, value: Text) {
        self.key = Text(key)
        self.value = value
    }

    init(verbatimKey: String, value: Text) {
        key = Text(verbatim: verbatimKey)
        self.value = value
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            key
                .lineLimit(1)
                .truncationMode(.middle)
                .textStyle(.body)
                .foregroundStyle(Palette.textSecondary)
            Spacer(minLength: Space.md)
            value
                .textStyle(.body)
                .foregroundStyle(Palette.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}

/// A filled SF Symbol in a soft round, the icon treatment of every row.
struct IconRound: View {
    let systemName: String
    var size: CGFloat = Size.rowAvatar

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: Size.rowIcon, weight: .semibold))
            .foregroundStyle(Palette.textPrimary)
            .frame(width: size, height: size)
            .background(Palette.inset, in: Circle())
            .accessibilityHidden(true)
    }
}

/// The pills of a screen's last line: one primary, filled with the text color; one secondary.
struct PillButtonStyle: ButtonStyle {
    enum Kind {
        case primary, secondary
    }

    let kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        PillBody(kind: kind, label: configuration.label, isPressed: configuration.isPressed)
    }
}

private struct PillBody<Label: View>: View {
    let kind: PillButtonStyle.Kind
    let label: Label
    let isPressed: Bool
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        label
            .textStyle(.rowTitle)
            .foregroundStyle(kind == .primary ? Palette.actionLabel : Palette.textPrimary)
            .frame(maxWidth: .infinity, minHeight: Size.pillHeight)
            .background(kind == .primary ? Palette.actionFill : Palette.inset, in: Capsule())
            .opacity(isEnabled ? (isPressed ? Tint.pressed : 1) : Tint.disabled)
            .scaleEffect(isPressed ? Tint.pressScale : 1)
            .animation(Motion.quick, value: isPressed)
    }
}

extension ButtonStyle where Self == PillButtonStyle {
    static var primaryPill: PillButtonStyle { PillButtonStyle(kind: .primary) }
    static var secondaryPill: PillButtonStyle { PillButtonStyle(kind: .secondary) }
}
