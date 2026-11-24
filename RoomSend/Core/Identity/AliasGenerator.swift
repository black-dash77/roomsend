import Foundation

/// Friendly names for a device, in the spirit of LocalSend's « Nice Orange ». The words and
/// their order come from the string catalog, so each language brings its own: the French list
/// pairs masculine fruits with masculine adjectives, so the agreement is always right.
nonisolated enum AliasGenerator {
    private static let separator: Character = ","

    static func make() -> String {
        var generator = SystemRandomNumberGenerator()
        return make(using: &generator)
    }

    static func make(using generator: inout some RandomNumberGenerator) -> String {
        let adjective = words(Localized.string("alias.adjectives")).randomElement(using: &generator) ?? ""
        let noun = words(Localized.string("alias.nouns")).randomElement(using: &generator) ?? ""
        return Localized.string("alias.format \(adjective) \(noun)")
    }

    private static func words(_ list: String) -> [String] {
        list.split(separator: separator).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
}
