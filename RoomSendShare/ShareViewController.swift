import OSLog
import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// The share sheet's RoomSend entry: collects what was shared, drops it in the inbox, and says
/// RoomSend will offer to send it.
final class ShareViewController: UIViewController {
    private static let closeDelay: Duration = .seconds(1.6)

    override func viewDidLoad() {
        super.viewDidLoad()
        let host = UIHostingController(rootView: ShareConfirmation())
        addChild(host)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(host.view)
        host.didMove(toParent: self)
        Task { await collect() }
    }

    private func collect() async {
        let providers = (extensionContext?.inputItems as? [NSExtensionItem] ?? []).flatMap { $0.attachments ?? [] }
        var files: [URL] = [], texts: [String] = []
        let scratch = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: true)
        for provider in providers {
            if let text = await Self.text(from: provider) { texts.append(text) }
            else if let file = await Self.file(from: provider, into: scratch) { files.append(file) }
        }
        do {
            try Inbox.store(files: files, texts: texts)
        } catch {
            Log.content.error("Shared items not stored: \(error.localizedDescription)")
        }
        try? await Task.sleep(for: Self.closeDelay)
        extensionContext?.completeRequest(returningItems: nil)
    }

    private static func text(from provider: NSItemProvider) async -> String? {
        if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            return try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) as? String
        }
        let isWebURL = provider.hasItemConformingToTypeIdentifier(UTType.url.identifier)
            && !provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
        guard isWebURL else { return nil }
        return (try? await provider.loadItem(forTypeIdentifier: UTType.url.identifier) as? URL)?.absoluteString
    }

    /// Copies the shared file before the system deletes its temporary copy.
    private static func file(from provider: NSItemProvider, into folder: URL) async -> URL? {
        guard let type = provider.registeredTypeIdentifiers.first else { return nil }
        return await withCheckedContinuation { continuation in
            _ = provider.loadFileRepresentation(forTypeIdentifier: type) { url, error in
                guard let url else {
                    Log.content.error("Shared file unreadable: \(error?.localizedDescription ?? "")")
                    return continuation.resume(returning: nil)
                }
                let copy = folder.appending(path: url.lastPathComponent)
                do {
                    try FileManager.default.copyItem(at: url, to: copy)
                    continuation.resume(returning: copy)
                } catch {
                    Log.content.error("Shared file not copied: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

private struct ShareConfirmation: View {
    var body: some View {
        VStack(spacing: Space.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: Size.objectIcon * 2, weight: .semibold))
                .foregroundStyle(Palette.live)
            Text("extension.title").textStyle(.title).foregroundStyle(Palette.textPrimary)
            Text("extension.detail").textStyle(.body).foregroundStyle(Palette.textSecondary).multilineTextAlignment(.center)
        }
        .padding(Space.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.background)
    }
}
