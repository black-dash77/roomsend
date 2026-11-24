import SwiftUI
import UIKit

/// What arrives: who sends, the object at the center, then Decline / Accept, the progress, and
/// the result. A message is shown whole, with Copy.
struct IncomingSheet: View {
    @Environment(ReceiveCoordinator.self) private var receiver
    @Environment(\.openURL) private var openURL

    private static let filesAppURL = URL(string: "shareddocuments://")
    private static let photosAppURL = URL(string: "photos-redirect://")

    var body: some View {
        VStack(spacing: Space.xxl) {
            if let sender { SenderLine(sender: sender) }
            content
            Spacer(minLength: 0)
            actions
        }
        .padding(.horizontal, Space.lg)
        .padding(.top, Space.xxl)
        .padding(.bottom, Space.sm)
        .background(Palette.background.ignoresSafeArea())
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(isBusy)
    }

    private var sender: DeviceInfo? {
        switch receiver.phase {
        case let .asking(offer), let .receiving(offer, _), let .finished(offer, _): offer.sender
        case let .message(sender, _): sender
        case .idle: nil
        }
    }

    private var isBusy: Bool {
        switch receiver.phase {
        case .asking, .receiving: true
        default: false
        }
    }

    @ViewBuilder
    private var content: some View {
        switch receiver.phase {
        case let .asking(offer):
            SendObject(summary: offer.summary, status: .pending, caption: Text("send.size.caption \(offer.summary.size)"))
            FileNames(files: offer.files)
        case let .receiving(offer, received):
            SendObject(summary: offer.summary, status: .pending, caption: Text("receive.progress \(received) \(offer.files.count)"))
        case let .finished(offer, _):
            SendObject(summary: offer.summary, status: .success, caption: Text("receive.done \(offer.sender.alias)"))
        case let .message(_, text):
            Block { Text(verbatim: text).textStyle(.title).foregroundStyle(Palette.textPrimary).textSelection(.enabled) }
        case .idle:
            EmptyView()
        }
    }

    @ViewBuilder
    private var actions: some View {
        switch receiver.phase {
        case .asking:
            HStack(spacing: Space.sm) {
                Button("receive.decline") { receiver.decline() }.buttonStyle(.secondaryPill)
                Button("receive.accept") { receiver.accept() }.buttonStyle(.primaryPill)
            }
        case .receiving:
            Button("send.stop") { receiver.stop() }.buttonStyle(.secondaryPill)
        case let .finished(_, isInPhotos):
            HStack(spacing: Space.sm) {
                Button(isInPhotos ? "receive.openPhotos" : "receive.openFiles") {
                    if let url = isInPhotos ? Self.photosAppURL : Self.filesAppURL { openURL(url) }
                }
                .buttonStyle(.secondaryPill)
                Button("send.done.action") { receiver.dismiss() }.buttonStyle(.primaryPill)
            }
        case let .message(_, text):
            HStack(spacing: Space.sm) {
                Button("receive.copy") { UIPasteboard.general.string = text }.buttonStyle(.secondaryPill)
                Button("send.done.action") { receiver.dismiss() }.buttonStyle(.primaryPill)
            }
        case .idle:
            EmptyView()
        }
    }
}

/// « Kiwi Malin t'envoie », with the sender's avatar and device badge.
private struct SenderLine: View {
    let sender: DeviceInfo

    var body: some View {
        HStack(spacing: Space.md) {
            IdentityAvatar(fingerprint: sender.fingerprint, size: Size.rowAvatar,
                           deviceType: sender.deviceType.flatMap(DeviceType.init(rawValue:)))
            Text("receive.from \(sender.alias)")
                .textStyle(.rowTitle)
                .foregroundStyle(Palette.textPrimary)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

/// The first names of what arrives, so the person knows what they accept.
private struct FileNames: View {
    let files: [IncomingPrepareUpload.File]

    private static let shown = 3

    var body: some View {
        Block {
            ForEach(files.prefix(Self.shown), id: \.id) { file in
                ValueRow(verbatimKey: file.fileName, value: Text(verbatim: file.size.formatted(.byteCount(style: .file))))
            }
            if files.count > Self.shown {
                Text("receive.more \(files.count - Self.shown)").textStyle(.meta).foregroundStyle(Palette.textSecondary)
            }
        }
    }
}
