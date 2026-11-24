import Foundation
import OSLog
import Photos

/// Moves received photos and videos into the photo library. What cannot be added stays in Files.
nonisolated enum PhotoSaver {
    /// True when every media is now in Photos.
    static func moveToPhotos(_ urls: [URL]) async -> Bool {
        guard !urls.isEmpty else { return false }
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            Log.receive.info("Photo library refused; the media stay in Files.")
            return false
        }
        var isEveryMediaMoved = true
        for url in urls {
            let isMoved = await move(url)
            isEveryMediaMoved = isEveryMediaMoved && isMoved
        }
        return isEveryMediaMoved
    }

    private static func move(_ url: URL) async -> Bool {
        let isVideo = ["mov", "mp4", "m4v", "hevc"].contains(url.pathExtension.lowercased())
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: isVideo ? .video : .photo, fileURL: url, options: nil)
            }
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            Log.receive.error("\(url.lastPathComponent) not added to Photos: \(error.localizedDescription)")
            return false
        }
    }
}
