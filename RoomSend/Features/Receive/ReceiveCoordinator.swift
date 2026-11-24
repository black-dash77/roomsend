import Foundation
import Observation
import OSLog

/// One reception, from the proposal to the last file: asks the person (or accepts at once),
/// hands out a token per file, writes each file where Files shows it, then files the photos.
@Observable
final class ReceiveCoordinator {
    enum Phase: Equatable {
        case idle
        case asking(IncomingOffer)
        case receiving(IncomingOffer, received: Int)
        /// `isInPhotos`: everything received was media and is now in the photo library.
        case finished(IncomingOffer, isInPhotos: Bool)
        case message(sender: DeviceInfo, text: String)
    }

    private(set) var phase: Phase = .idle

    private let settings: ReceiveSettings
    private let history: HistoryStore
    private var decision: CheckedContinuation<Bool, Never>?
    private var session: ReceiveSession?

    init(settings: ReceiveSettings, history: HistoryStore) {
        self.settings = settings
        self.history = history
    }

    // MARK: Requests from the server

    func prepare(_ request: IncomingPrepareUpload, pin: String?) async -> PrepareOutcome {
        guard settings.accepts(pin: pin) else { return .pinRequired }
        guard session == nil, decision == nil else { return .busy }
        let offer = IncomingOffer(id: UUID().uuidString, sender: request.info, files: Array(request.files.values))
        if let text = offer.message {
            phase = .message(sender: offer.sender, text: text)
            history.record(received: offer)
            return .nothingToTransfer
        }
        let isAccepted = settings.acceptsAutomatically ? true : await ask(offer)
        guard isAccepted else {
            phase = .idle
            return .rejected
        }
        let session = ReceiveSession(offer: offer)
        self.session = session
        phase = .receiving(offer, received: 0)
        return .accepted(sessionID: session.id, tokens: session.tokens)
    }

    /// Where an announced file goes, if its session and token match.
    func destination(session id: String, file: String, token: String) -> URL? {
        guard let session, session.id == id, session.tokens[file] == token else { return nil }
        return session.destinations[file]
    }

    /// Marks a file as arrived. The sender gets its answer at once: filing the photos may wait
    /// for the person to allow the photo library, and that wait must not hold the transfer.
    func didReceive(session id: String, file: String) {
        guard var session, session.id == id else { return }
        session.received.insert(file)
        self.session = session
        phase = .receiving(session.offer, received: session.received.count)
        guard session.received.count == session.offer.files.count else { return }
        self.session = nil
        Task { await finish(session) }
    }

    func cancel(session id: String) {
        guard session?.id == id else { return }
        session = nil
        phase = .idle
    }

    /// The person stops a reception under way: the files still to come are refused.
    func stop() {
        guard case .receiving = phase else { return }
        session = nil
        phase = .idle
    }

    // MARK: The person's answer

    func accept() { answer(true) }
    func decline() { answer(false) }

    func dismiss() {
        if case .asking = phase { return }
        phase = .idle
    }

    private func ask(_ offer: IncomingOffer) async -> Bool {
        phase = .asking(offer)
        return await withCheckedContinuation { decision = $0 }
    }

    private func answer(_ accepted: Bool) {
        decision?.resume(returning: accepted)
        decision = nil
    }

    private func finish(_ session: ReceiveSession) async {
        var isInPhotos = false
        if settings.savesMediaToPhotos {
            let isEveryMediaMoved = await PhotoSaver.moveToPhotos(session.mediaURLs)
            isInPhotos = isEveryMediaMoved && session.mediaURLs.count == session.offer.files.count
        }
        history.record(received: session.offer)
        phase = .finished(session.offer, isInPhotos: isInPhotos)
    }
}

/// The tokens and destinations of the files of one accepted offer.
nonisolated struct ReceiveSession: Sendable {
    let id = UUID().uuidString
    let offer: IncomingOffer
    let tokens: [String: String]
    let destinations: [String: URL]
    var received: Set<String> = []

    init(offer: IncomingOffer) {
        self.offer = offer
        tokens = Dictionary(uniqueKeysWithValues: offer.files.map { ($0.id, UUID().uuidString) })
        destinations = Dictionary(uniqueKeysWithValues: offer.files.map { ($0.id, ReceivedFiles.uniqueURL(for: $0.fileName)) })
    }

    var mediaURLs: [URL] {
        offer.files.filter { IncomingOffer.isMedia($0.fileType) }.compactMap { destinations[$0.id] }
    }
}

/// Received files live in the app's Documents folder, which the Files app shows as « RoomSend ».
nonisolated enum ReceivedFiles {
    static var folder: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// `name`, or `name 2`, `name 3`… when a file of that name is already there.
    static func uniqueURL(for name: String) -> URL {
        let safe = (name as NSString).lastPathComponent
        let base = (safe as NSString).deletingPathExtension
        let ext = (safe as NSString).pathExtension
        var candidate = folder.appending(path: safe)
        var number = 2
        while FileManager.default.fileExists(atPath: candidate.path(percentEncoded: false)) {
            candidate = folder.appending(path: ext.isEmpty ? "\(base) \(number)" : "\(base) \(number).\(ext)")
            number += 1
        }
        return candidate
    }
}
