import Foundation

/// One of the two legal documents, written once in `tools/legal` for the app and the site, and
/// kept in the catalog so it reads without Internet, in the language picked in Settings.
nonisolated enum LegalDocument: String, Identifiable, Sendable {
    case privacy, terms

    var id: Self { self }

    var title: String.LocalizationValue {
        switch self {
        case .privacy: "legal.privacy.title"
        case .terms: "legal.terms.title"
        }
    }

    var updated: String.LocalizationValue {
        switch self {
        case .privacy: "legal.privacy.updated"
        case .terms: "legal.terms.updated"
        }
    }

    var body: String.LocalizationValue {
        switch self {
        case .privacy: "legal.privacy.body"
        case .terms: "legal.terms.body"
        }
    }

    /// The same document on the site, in the given language: English at the root, the other
    /// languages under their code, as `site/build.py` publishes them.
    func siteURL(language: String) -> URL? {
        let prefix = language == Self.siteDefaultLanguage ? "" : "/\(language)"
        return URL(string: "\(Self.siteAddress)\(prefix)/\(rawValue)/")
    }

    private static let siteAddress = "https://roomsend.netlify.app"
    private static let siteDefaultLanguage = "en"
}

/// A part of a document: its heading (none for the introduction) and what follows it.
nonisolated struct LegalSection: Identifiable, Sendable {
    let id: Int
    let heading: String?
    let blocks: [LegalBlock]
}

nonisolated enum LegalBlock: Hashable, Sendable {
    case paragraph(AttributedString)
    case list([AttributedString])
}

/// Reads the plain format `tools/legal` writes: blocks apart by a blank line, `## ` opening a
/// section, `- ` starting each item of a list, links inline as Markdown.
nonisolated enum LegalText {
    private static let blockSeparator = "\n\n"
    private static let headingMarker = "## "
    private static let itemMarker = "- "

    static func sections(from text: String) -> [LegalSection] {
        var sections: [LegalSection] = []
        var heading: String?
        var blocks: [LegalBlock] = []
        for chunk in text.components(separatedBy: blockSeparator) where !chunk.isEmpty {
            if chunk.hasPrefix(headingMarker) {
                if heading != nil || !blocks.isEmpty {
                    sections.append(LegalSection(id: sections.count, heading: heading, blocks: blocks))
                }
                heading = String(chunk.dropFirst(headingMarker.count))
                blocks = []
            } else {
                blocks.append(block(from: chunk))
            }
        }
        sections.append(LegalSection(id: sections.count, heading: heading, blocks: blocks))
        return sections
    }

    private static func block(from chunk: String) -> LegalBlock {
        guard chunk.hasPrefix(itemMarker) else { return .paragraph(inline(chunk)) }
        let items = chunk.split(separator: "\n").map { inline(String($0.dropFirst(itemMarker.count))) }
        return .list(items)
    }

    private static func inline(_ text: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
    }
}
