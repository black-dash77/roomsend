import Foundation

/// One thing to send, already copied to a temporary file so it can be streamed from disk.
nonisolated struct OutgoingItem: Identifiable, Equatable, Sendable {
    enum Kind: Sendable {
        case photo, file, text
    }

    let id: String
    let kind: Kind
    let fileName: String
    let fileType: String
    let size: Int64
    let fileURL: URL
    /// The text itself for a message: receivers show it without opening a file.
    let preview: String?
}

/// Why a transfer stopped (protocol v2.2, section 4.1 errors, plus the network itself).
nonisolated enum TransferError: Error, Equatable, Sendable {
    case unreachable
    case rejected
    case pinRequired
    case busy
    case invalidResponse
    case cancelled
    case receiver(code: Int)
}

/// `POST /prepare-upload` body: who sends, and the metadata of each file.
nonisolated struct PrepareUploadRequest: Encodable, Sendable {
    nonisolated struct FileMetadata: Encodable, Sendable {
        let id: String
        let fileName: String
        let size: Int64
        let fileType: String
        let preview: String?
    }

    let info: DeviceInfo
    let files: [String: FileMetadata]

    init(sender: DeviceInfo, items: [OutgoingItem]) {
        info = sender
        files = Dictionary(uniqueKeysWithValues: items.map { item in
            (item.id, FileMetadata(
                id: item.id, fileName: item.fileName, size: item.size,
                fileType: item.fileType, preview: item.preview
            ))
        })
    }
}

/// `POST /prepare-upload` answer: the session, and one token per accepted file.
nonisolated struct PrepareUploadResponse: Codable, Sendable {
    let sessionId: String
    let files: [String: String]
}
