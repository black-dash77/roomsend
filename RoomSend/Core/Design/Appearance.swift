import SwiftUI

/// Day, night, or whatever the iPhone is set to. Stored under `storageKey`; the root view
/// applies it, so the whole app flips the moment it is chosen.
nonisolated enum Appearance: String, CaseIterable, Identifiable, Sendable {
    case system, light, dark

    static let storageKey = "appearance"

    var id: Self { self }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .system: "settings.appearance.system"
        case .light: "settings.appearance.light"
        case .dark: "settings.appearance.dark"
        }
    }
}
