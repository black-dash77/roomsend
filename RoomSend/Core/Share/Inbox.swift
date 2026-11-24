import Foundation
import OSLog

/// The box the share extension fills and the app empties: files shared from another app wait
/// there, in the app group's container, until RoomSend opens and offers to send them.
nonisolated enum Inbox {
    static let groupID = "group.app.roomsend.ios"
    /// The name a shared text is written under, so the app reads it back as a message.
    static let textFileName = "shared-text.txt"

    private static var folder: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?
            .appending(path: "Inbox", directoryHint: .isDirectory)
    }

    /// Extension side: copies each file and writes each text into a fresh batch.
    static func store(files: [URL], texts: [String]) throws {
        guard let folder else { throw CocoaError(.fileNoSuchFile) }
        let batch = folder.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: batch, withIntermediateDirectories: true)
        for file in files {
            try FileManager.default.copyItem(at: file, to: batch.appending(path: file.lastPathComponent))
        }
        if !texts.isEmpty {
            try Data(texts.joined(separator: "\n\n").utf8).write(to: batch.appending(path: textFileName))
        }
    }

    /// App side: every waiting file, the inbox emptied. The caller copies what it keeps.
    static func takeAll() -> [URL] {
        guard let folder, let batches = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else {
            return []
        }
        let files = batches.flatMap { batch in
            (try? FileManager.default.contentsOfDirectory(at: batch, includingPropertiesForKeys: nil)) ?? []
        }
        return files
    }

    /// Removes the batches once their files were copied for sending.
    static func clear() {
        guard let folder else { return }
        do {
            try FileManager.default.removeItem(at: folder)
        } catch {
            Log.content.info("Inbox already empty: \(error.localizedDescription)")
        }
    }
}
