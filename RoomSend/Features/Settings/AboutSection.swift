import SwiftUI

/// What this device runs and how others recognise it, then the two legal documents, each
/// opened in a sheet of ours that reads without Internet.
struct AboutSection: View {
    @Environment(IdentityStore.self) private var identity
    @State private var openDocument: LegalDocument?

    private static let shortFingerprintLength = 12

    var body: some View {
        Block(label: "settings.about") {
            ValueRow(key: "settings.fingerprint", value: Text(verbatim: shortFingerprint))
            ValueRow(key: "settings.protocol", value: Text(verbatim: "LocalSend \(LocalSendProtocol.version)"))
            ValueRow(key: "settings.version", value: Text(verbatim: appVersion))
            DocumentRow(title: "settings.privacy") { openDocument = .privacy }
            DocumentRow(title: "settings.terms") { openDocument = .terms }
        }
        .sheet(item: $openDocument) { document in LegalScreen(document: document) }
    }

    private var shortFingerprint: String {
        String(identity.identity.fingerprint.prefix(Self.shortFingerprintLength)).uppercased()
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
}

/// A row that opens a document: its title, and the chevron that says it leads somewhere.
private struct DocumentRow: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .textStyle(.rowTitle)
                    .foregroundStyle(Palette.textPrimary)
                Spacer(minLength: Space.md)
                Image(systemName: "chevron.right")
                    .textStyle(.meta)
                    .foregroundStyle(Palette.textMuted)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: Size.touch)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
