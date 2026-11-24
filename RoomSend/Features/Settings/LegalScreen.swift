import SwiftUI

/// A legal document in a sheet of ours: its title and date, then one block per section, the
/// close button fixed above the text that scrolls under it.
struct LegalScreen: View {
    let document: LegalDocument
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var language

    var body: some View {
        let locale = language.locale
        ScrollView {
            VStack(alignment: .leading, spacing: Space.md) {
                VStack(alignment: .leading, spacing: Space.xs) {
                    Text(verbatim: Localized.string(document.title, locale: locale))
                        .textStyle(.screenTitle)
                        .foregroundStyle(Palette.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text(verbatim: Localized.string(document.updated, locale: locale))
                        .textStyle(.meta)
                        .foregroundStyle(Palette.textSecondary)
                }
                .padding(.bottom, Space.sm)
                ForEach(LegalText.sections(from: Localized.string(document.body, locale: locale))) { section in
                    LegalSectionBlock(section: section)
                }
                if let url = document.siteURL(language: language.language.code) {
                    Link(destination: url) {
                        Label("legal.openSite", systemImage: "safari")
                    }
                    .buttonStyle(.secondaryPill)
                    .padding(.top, Space.sm)
                }
            }
            .padding(.horizontal, Space.lg)
            .padding(.bottom, Space.huge)
        }
        .scrollIndicators(.hidden)
        .safeAreaBar(edge: .top) { closeBar }
        .scrollEdgeEffectStyle(.soft, for: .top)
        .background(Palette.background.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }

    private var closeBar: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: Size.rowIcon, weight: .semibold))
                    .foregroundStyle(Palette.textPrimary)
                    .frame(width: Size.touch, height: Size.touch)
            }
            .glassEffect(.regular.interactive(), in: Circle())
            .accessibilityLabel(Text("legal.close"))
        }
        .padding(.horizontal, Space.lg)
        .padding(.top, Space.lg)
    }
}

/// One section: its heading, its paragraphs, and its lists as tiles inside the block.
private struct LegalSectionBlock: View {
    let section: LegalSection

    var body: some View {
        Block {
            if let heading = section.heading {
                Text(verbatim: heading)
                    .textStyle(.rowTitle)
                    .foregroundStyle(Palette.textPrimary)
                    .accessibilityAddTraits(.isHeader)
            }
            ForEach(section.blocks, id: \.self) { block in
                switch block {
                case let .paragraph(text):
                    paragraph(text)
                case let .list(items):
                    ForEach(items, id: \.self) { item in
                        paragraph(item)
                            .padding(Space.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Palette.inset, in: RoundedRectangle(cornerRadius: Radius.inset, style: .continuous))
                    }
                }
            }
        }
    }

    private func paragraph(_ text: AttributedString) -> some View {
        Text(text)
            .textStyle(.body)
            .foregroundStyle(Palette.textSecondary)
            .tint(Palette.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
