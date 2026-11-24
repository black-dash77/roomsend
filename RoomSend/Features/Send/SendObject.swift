import SwiftUI

/// The object of a transfer, centered and large, as MetaMask centers « 1 ETH »: a small stack of
/// what moves, its name in one phrase, a caption under it. The stack becomes a check or a warning.
struct SendObject: View {
    enum Status: Equatable {
        case pending, success, failure
    }

    let summary: SendSummary
    let status: Status
    let caption: Text

    private static let stackDepth = 3

    var body: some View {
        VStack(spacing: Space.md) {
            symbol
                .frame(height: Size.objectTile + Space.xl)
            Text(verbatim: summary.title)
                .textStyle(.object)
                .foregroundStyle(Palette.textPrimary)
                .multilineTextAlignment(.center)
            caption
                .textStyle(.body)
                .foregroundStyle(Palette.textSecondary)
                .multilineTextAlignment(.center)
                .contentTransition(.numericText())
        }
        .animation(Motion.settle, value: status)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var symbol: some View {
        switch status {
        case .success: badge("checkmark", color: Palette.live)
        case .failure: badge("exclamationmark", color: Palette.danger)
        case .pending: stack
        }
    }

    private var stack: some View {
        ZStack {
            ForEach(0..<Self.stackDepth, id: \.self) { layer in
                RoundedRectangle(cornerRadius: Radius.tile, style: .continuous)
                    .fill(layer == Self.stackDepth - 1 ? Palette.block : Palette.inset)
                    .frame(width: Size.objectTile, height: Size.objectTile)
                    .rotationEffect(.degrees(Double(layer - 1) * Tint.objectTilt))
                    .offset(x: CGFloat(layer - 1) * Space.md)
            }
            Image(systemName: summary.symbolName)
                .font(.system(size: Size.objectIcon, weight: .semibold))
                .foregroundStyle(Palette.textPrimary)
                .offset(x: Space.md)
        }
        .transition(.scale(scale: Motion.entranceScale).combined(with: .opacity))
    }

    private func badge(_ systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: Size.objectIcon, weight: .heavy))
            .foregroundStyle(Palette.actionLabel)
            .frame(width: Size.objectTile, height: Size.objectTile)
            .background(color, in: Circle())
            .transition(.scale(scale: Motion.entranceScale).combined(with: .opacity))
    }
}

extension SendFlow.Phase {
    var objectStatus: SendObject.Status {
        switch self {
        case .sent: .success
        case .failed: .failure
        default: .pending
        }
    }

    func caption(for summary: SendSummary) -> Text {
        switch self {
        case let .sending(alias, sent, total):
            Text("send.progress.bytes \(alias) \(sent.formatted(.byteCount(style: .file))) \(total.formatted(.byteCount(style: .file)))")
        case let .needsPin(alias, isRetry): Text(isRetry ? "send.pin.wrong \(alias)" : "send.pin.ask \(alias)")
        case let .sent(alias): alias.map { Text("send.done \($0)") } ?? Text("send.done.everyone")
        case let .failed(error): Text(error.message)
        case .reviewing: Text("send.size.caption \(summary.size)")
        }
    }
}
