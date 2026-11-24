import SwiftUI

/// The language of the app, picked here and applied at once. Each pill is written in its own
/// language, so anyone finds theirs even when the screen speaks another one.
struct LanguageSection: View {
    @Environment(LanguageSettings.self) private var settings

    private static let columnCount = 3
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Space.sm), count: columnCount)
    private let languages = AppLanguage.allCases.filter { $0 != .system }

    var body: some View {
        Block(label: "settings.language") {
            pill(for: .system)
            LazyVGrid(columns: columns, spacing: Space.sm) {
                ForEach(languages) { language in pill(for: language) }
            }
            Text("settings.language.detail")
                .textStyle(.meta)
                .foregroundStyle(Palette.textSecondary)
        }
    }

    private func pill(for language: AppLanguage) -> some View {
        let isSelected = language == settings.language
        return Button {
            withAnimation(Motion.settle) { settings.choose(language) }
        } label: {
            name(of: language)
                .textStyle(.rowTitle)
                .lineLimit(1)
                .minimumScaleFactor(Tint.carouselMinScale)
                .foregroundStyle(isSelected ? Palette.actionLabel : Palette.textPrimary)
                .frame(maxWidth: .infinity, minHeight: Size.touch)
                .background(isSelected ? Palette.actionFill : Palette.inset, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// The language's own name, tagged with its language so VoiceOver reads it with the right voice.
    private func name(of language: AppLanguage) -> Text {
        guard let endonym = language.endonym else { return Text("settings.appearance.system") }
        var name = AttributedString(endonym)
        name.languageIdentifier = language.rawValue
        return Text(name)
    }
}
