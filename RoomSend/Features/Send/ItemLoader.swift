import Foundation
import OSLog
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

/// Turns what the user picked into `OutgoingItem`s, each copied to its own temporary file.
enum ItemLoader {
    private static let textFileName = "message.txt"
    private static let fallbackType = "application/octet-stream"

    static func items(from photos: [PhotosPickerItem]) async -> [OutgoingItem] {
        var items: [OutgoingItem] = []
        for (index, photo) in photos.enumerated() {
            if let item = await item(from: photo, number: index + 1) { items.append(item) }
        }
        return items
    }

    static func items(from urls: [URL]) -> [OutgoingItem] {
        urls.compactMap(item(from:))
    }

    static func item(fromText text: String) -> OutgoingItem? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let data = Data(trimmed.utf8)
        return write(data, named: textFileName, type: UTType.plainText, kind: .text, preview: trimmed)
    }

    private static func item(from photo: PhotosPickerItem, number: Int) async -> OutgoingItem? {
        let type = photo.supportedContentTypes.first ?? .jpeg
        do {
            guard let data = try await photo.loadTransferable(type: Data.self) else { return nil }
            let name = Localized.string("file.photo \(number)") + ".\(type.preferredFilenameExtension ?? "jpg")"
            return write(data, named: name, type: type, kind: .photo, preview: nil)
        } catch {
            Log.content.error("Photo \(number) not loaded: \(error.localizedDescription)")
            return nil
        }
    }

    private static func item(from url: URL) -> OutgoingItem? {
        let isScoped = url.startAccessingSecurityScopedResource()
        defer { if isScoped { url.stopAccessingSecurityScopedResource() } }
        do {
            let data = try Data(contentsOf: url)
            let type = UTType(filenameExtension: url.pathExtension) ?? .data
            let kind: OutgoingItem.Kind = type.conforms(to: .image) || type.conforms(to: .movie) ? .photo : .file
            return write(data, named: url.lastPathComponent, type: type, kind: kind, preview: nil)
        } catch {
            Log.content.error("File \(url.lastPathComponent) not read: \(error.localizedDescription)")
            return nil
        }
    }

    private static func write(
        _ data: Data, named name: String, type: UTType, kind: OutgoingItem.Kind, preview: String?
    ) -> OutgoingItem? {
        let id = UUID().uuidString
        let folder = FileManager.default.temporaryDirectory.appending(path: id, directoryHint: .isDirectory)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let url = folder.appending(path: name)
            try data.write(to: url)
            return OutgoingItem(
                id: id, kind: kind, fileName: name, fileType: type.preferredMIMEType ?? fallbackType,
                size: Int64(data.count), fileURL: url, preview: preview
            )
        } catch {
            Log.content.error("Temporary copy of \(name) failed: \(error.localizedDescription)")
            return nil
        }
    }
}
