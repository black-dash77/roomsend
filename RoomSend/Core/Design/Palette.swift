import SwiftUI
import UIKit

/// The block colors of 4.5 (« Breath » palette), light and dark, hex for hex. The interface
/// stays neutral: color comes from the devices themselves (`IdentityPalette`), the way Revolut
/// and MetaMask take theirs from flags and token logos.
nonisolated enum Palette {
    static let background = Color(light: 0xF8F9FA, dark: 0x000000)
    static let block = Color(light: 0xFFFFFF, dark: 0x0C0C0C)
    /// A surface inside a block: icon rounds, tiles, the secondary pill.
    static let inset = Color(light: 0xF1F3F5, dark: 0x1A1A1A)
    static let textPrimary = Color(light: 0x09090B, dark: 0xFAFAFA)
    static let textSecondary = Color(light: 0x52525B, dark: 0xA1A1AA)
    static let textMuted = Color(light: 0xA1A1AA, dark: 0x71717A)
    static let separator = Color(light: 0xE2E4E9, dark: 0x1A1A1A)
    /// The one primary action of a screen: the text color as a fill, its label inverted.
    static let actionFill = Color(light: 0x09090B, dark: 0xFAFAFA)
    static let actionLabel = Color(light: 0xFAFAFA, dark: 0x09090B)
    static let live = Color(light: 0x10B981, dark: 0x34D399)
    static let danger = Color(light: 0xEF4444, dark: 0xF87171)
}

/// The colors a device identity is drawn from. Flat and saturated, so two avatars side by side
/// never look alike; each one reads on white and on black.
nonisolated enum IdentityPalette {
    static let hexes: [UInt32] = [
        0xFF5A36, 0xFF9F1C, 0xFFD23F, 0xB8F34A,
        0x2EC4B6, 0x3A86FF, 0xFF4D8D, 0x9B5DE5,
    ]

    static func color(at index: Int) -> Color {
        Color(hex: hexes[index % hexes.count])
    }
}

extension Color {
    /// A color that follows light and dark mode, from two hex values.
    nonisolated init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    nonisolated init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }
}

extension UIColor {
    nonisolated convenience init(hex: UInt32) {
        let channel = { (shift: UInt32) in CGFloat((hex >> shift) & 0xFF) / 255 }
        self.init(red: channel(16), green: channel(8), blue: channel(0), alpha: 1)
    }
}
