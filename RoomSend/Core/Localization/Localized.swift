import Foundation

/// Text built outside the views (file names, summaries, the share page) in the language picked
/// in Settings. It is looked up in that language's own table, so a new pick applies at once,
/// without a relaunch.
nonisolated enum Localized {
    static func string(_ value: String.LocalizationValue, locale: Locale = AppLanguage.active.locale) -> String {
        String(localized: value, bundle: table(for: locale), locale: locale)
    }

    static func attributed(_ value: String.LocalizationValue, locale: Locale = AppLanguage.active.locale) -> AttributedString {
        AttributedString(localized: value, bundle: table(for: locale), locale: locale)
    }

    private static func table(for locale: Locale) -> Bundle {
        let code = locale.language.languageCode?.identifier ?? AppLanguage.en.rawValue
        return Bundle.main.path(forResource: code, ofType: "lproj").flatMap(Bundle.init(path:)) ?? .main
    }
}
