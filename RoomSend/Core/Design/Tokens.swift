import SwiftUI

/// Spacing of 4.5, value for value.
nonisolated enum Space {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let huge: CGFloat = 48
}

/// Corner radii, drawn as continuous curves. Blocks take `block`; what sits inside a block
/// takes `inset`, its radius minus the block padding.
nonisolated enum Radius {
    static let inset: CGFloat = 12
    static let tile: CGFloat = 18
    static let block: CGFloat = 24
}

nonisolated enum Size {
    static let touch: CGFloat = 44
    static let rowAvatar: CGFloat = 44
    static let rowIcon: CGFloat = 20
    static let badge: CGFloat = 18
    static let badgeIcon: CGFloat = 9
    static let stackAvatar: CGFloat = 52
    static let heroAvatar: CGFloat = 96
    static let tileHeight: CGFloat = 76
    static let tileIcon: CGFloat = 22
    static let pillHeight: CGFloat = 54
    static let liveDot: CGFloat = 8
    static let identityChip: CGFloat = 30
    static let avatarRing: CGFloat = 3
    static let recipientAvatar: CGFloat = 72
    static let recipientWidth: CGFloat = 104
    static let carouselHeight: CGFloat = 112
    static let objectTile: CGFloat = 72
    static let objectIcon: CGFloat = 28
    static let settingsAvatar: CGFloat = 64
    static let listeningRing: CGFloat = 1.5
    static let listeningDash: [CGFloat] = [4, 5]
    static let sourceSheetHeight: CGFloat = 380
}

/// Opacities and the proximity effect of carousels (the center is the choice).
nonisolated enum Tint {
    static let pressed: Double = 0.72
    static let disabled: Double = 0.35
    static let pressScale: CGFloat = 0.97
    static let carouselMinScale: CGFloat = 0.72
    static let carouselMinOpacity: Double = 0.4
    static let objectTilt: Double = 7
    /// Share of a carousel's width that fades out on each side.
    static let edgeFade: Double = 0.12
}

/// How much one avatar of a stack covers the previous one.
nonisolated enum Overlap {
    static let stack: CGFloat = 0.32
    static let maxVisible = 4
    /// Beyond this many devices, the room's list scrolls inside its block.
    static let maxRows = 4
}

/// Entrances decelerate and settle; what lives on screen moves slowly.
enum Motion {
    static let settle: Animation = .smooth(duration: 0.38)
    static let quick: Animation = .snappy(duration: 0.22)
    static let entranceScale: CGFloat = 0.94
    static let pulsePeriod: Double = 4.6
}

/// The type scale, one family for everything: SF Pro at its normal width, titles bold like the
/// rest of the interface. One dominant figure per screen (`hero`); everything else stays small,
/// on three levels.
nonisolated enum TextStyle {
    case hero, heroUnit, screenTitle, object, title, rowTitle, body, meta, label

    var size: CGFloat {
        switch self {
        case .hero: 88
        case .heroUnit: 24
        case .screenTitle: 34
        case .object: 40
        case .title: 22
        case .rowTitle: 16
        case .body: 15
        case .meta: 13
        case .label: 12
        }
    }

    var weight: Font.Weight {
        switch self {
        case .hero, .screenTitle, .object, .title: .bold
        case .heroUnit, .rowTitle, .label: .semibold
        case .body, .meta: .regular
        }
    }

    var tracking: CGFloat {
        switch self {
        case .hero: -2.5
        case .screenTitle, .object: -0.8
        case .heroUnit: -0.5
        case .title: -0.4
        case .label: 0.2
        default: 0
        }
    }
}

extension TextStyle {
    var font: Font {
        .system(size: size, weight: weight)
    }
}

extension View {
    func textStyle(_ style: TextStyle) -> some View {
        font(style.font).tracking(style.tracking)
    }
}
