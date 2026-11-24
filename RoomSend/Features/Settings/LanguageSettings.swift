import Foundation
import Observation

/// The language picked in Settings. The root view applies its locale, so the whole app changes
/// language the moment a pill is touched.
@Observable
final class LanguageSettings {
    private(set) var language = AppLanguage.active

    var locale: Locale { language.locale }

    func choose(_ language: AppLanguage) {
        language.activate()
        self.language = language
    }
}
