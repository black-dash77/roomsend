import SwiftUI

/// What a send contains, said in one short phrase: « 3 photos », « 2 fichiers », « Un message ».
nonisolated struct SendSummary: Equatable, Sendable {
    let photoCount: Int
    let fileCount: Int
    let textCount: Int
    let byteCount: Int64

    init(photoCount: Int, fileCount: Int, textCount: Int, byteCount: Int64) {
        self.photoCount = photoCount
        self.fileCount = fileCount
        self.textCount = textCount
        self.byteCount = byteCount
    }

    init(items: [OutgoingItem]) {
        photoCount = items.count { $0.kind == .photo }
        fileCount = items.count { $0.kind == .file }
        textCount = items.count { $0.kind == .text }
        byteCount = items.reduce(0) { $0 + $1.size }
    }

    init(record: TransferRecord) {
        photoCount = record.photoCount
        fileCount = record.fileCount
        textCount = record.textCount
        byteCount = record.byteCount
    }

    var title: String {
        if textCount > 0, photoCount + fileCount == 0 { return Localized.string("send.summary.text") }
        if fileCount == 0 { return Localized.string("send.summary.photos \(photoCount)") }
        if photoCount == 0 { return Localized.string("send.summary.files \(fileCount)") }
        return Localized.string("send.summary.items \(photoCount + fileCount + textCount)")
    }

    var symbolName: String {
        if textCount > 0, photoCount + fileCount == 0 { return ContentSource.text.symbolName }
        return fileCount == 0 ? ContentSource.photos.symbolName : ContentSource.files.symbolName
    }

    var size: String {
        byteCount.formatted(.byteCount(style: .file))
    }
}

extension TransferError {
    /// What the person reads when a send stops.
    var message: LocalizedStringKey {
        switch self {
        case .unreachable: "error.unreachable"
        case .rejected: "error.rejected"
        case .pinRequired: "error.pinRequired"
        case .busy: "error.busy"
        case .invalidResponse: "error.invalidResponse"
        case .cancelled: "error.cancelled"
        case let .receiver(code): "error.receiver \(code)"
        }
    }
}
