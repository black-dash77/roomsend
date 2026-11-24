import Foundation

/// `POST /prepare-upload`, as a receiver reads it.
nonisolated struct IncomingPrepareUpload: Decodable, Sendable {
    nonisolated struct File: Decodable, Equatable, Sendable {
        let id: String
        let fileName: String
        let size: Int64
        let fileType: String
        let preview: String?
    }

    let info: DeviceInfo
    let files: [String: File]
}

/// What a sender proposes: who, and which files.
nonisolated struct IncomingOffer: Identifiable, Equatable, Sendable {
    let id: String
    let sender: DeviceInfo
    let files: [IncomingPrepareUpload.File]

    private static let textType = "text/plain"
    private static let imagePrefix = "image/"
    private static let videoPrefix = "video/"

    /// A message: text files carrying their text as preview. Shown at once, nothing to download.
    var message: String? {
        guard !files.isEmpty, files.allSatisfy({ $0.fileType.hasPrefix(Self.textType) && $0.preview != nil }) else { return nil }
        return files.compactMap(\.preview).joined(separator: "\n\n")
    }

    var summary: SendSummary {
        let media = files.count { Self.isMedia($0.fileType) }
        return SendSummary(
            photoCount: media,
            fileCount: files.count - media,
            textCount: 0,
            byteCount: files.reduce(0) { $0 + $1.size }
        )
    }

    static func isMedia(_ fileType: String) -> Bool {
        fileType.hasPrefix(imagePrefix) || fileType.hasPrefix(videoPrefix)
    }
}

/// The answer to a proposal (protocol v2.2, section 4.1).
nonisolated enum PrepareOutcome: Sendable {
    case accepted(sessionID: String, tokens: [String: String])
    case nothingToTransfer
    case pinRequired
    case rejected
    case busy
}
