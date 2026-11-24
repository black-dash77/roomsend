import Foundation
import os

/// The language of the interface: the iPhone's, or one the person picks among the app's own.
/// The pick is kept where iOS keeps an app's language (`AppleLanguages` in the app's defaults):
/// the system dialogs and the next launch follow it, and Settings › RoomSend agrees with it.
nonisolated enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system, en, fr, de, es, it, pt

    var id: Self { self }

    /// The pick in effect, readable from any thread by the text built outside the views.
    static var active: AppLanguage { activeLanguage.withLock { $0 } }

    private static let preferencesKey = "AppleLanguages"
    private static let activeLanguage = OSAllocatedUnfairLock(initialState: stored())

    /// The pick kept for this app; `.system` when iOS decides.
    static func stored(in defaults: UserDefaults = .standard) -> AppLanguage {
        guard let domain = Bundle.main.bundleIdentifier,
              let first = (defaults.persistentDomain(forName: domain)?[preferencesKey] as? [String])?.first
        else { return .system }
        return allCases.first { $0 != .system && first.hasPrefix($0.rawValue) } ?? .system
    }

    /// Makes this pick the one in effect, now and at the next launch.
    func activate(in defaults: UserDefaults = .standard) {
        if self == .system {
            defaults.removeObject(forKey: Self.preferencesKey)
        } else {
            defaults.set([rawValue], forKey: Self.preferencesKey)
        }
        Self.activeLanguage.withLock { $0 = self }
    }

    /// The localization shown: the pick, or the iPhone's best match among the app's languages.
    var code: String {
        guard self == .system else { return rawValue }
        let preferred = UserDefaults.standard.stringArray(forKey: Self.preferencesKey) ?? Locale.preferredLanguages
        return Bundle.preferredLocalizations(from: Bundle.main.localizations, forPreferences: preferred).first
            ?? Self.en.rawValue
    }

    /// The language with the person's region, so numbers and dates keep their usual form.
    var locale: Locale {
        Locale(languageCode: Locale.LanguageCode(code), languageRegion: Locale.current.region)
    }

    /// The language's own name, written in itself (« Deutsch », « Français »); nil for `.system`.
    var endonym: String? {
        guard self != .system else { return nil }
        let own = Locale(identifier: rawValue)
        return own.localizedString(forLanguageCode: rawValue)?.capitalized(with: own)
    }
}
