import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

/// The shared link: a QR code to scan, the address to type, and « Stop sharing ».
struct ShareLinkSheet: View {
    @Environment(ShareLink.self) private var link
    @Environment(\.dismiss) private var dismiss

    private static let codeScale: CGFloat = 12

    var body: some View {
        VStack(spacing: Space.xl) {
            Text("share.title")
                .textStyle(.screenTitle)
                .foregroundStyle(Palette.textPrimary)
            switch link.status {
            case let .ready(url):
                if let code = Self.qrCode(for: url) {
                    Image(uiImage: code)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(Space.lg)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: Radius.block, style: .continuous))
                        .accessibilityLabel(Text("share.code"))
                }
                Text(verbatim: url.absoluteString)
                    .textStyle(.title)
                    .foregroundStyle(Palette.textPrimary)
                    .textSelection(.enabled)
                Text("share.detail")
                    .textStyle(.body)
                    .foregroundStyle(Palette.textSecondary)
                    .multilineTextAlignment(.center)
            case .noWiFi:
                notice("share.unavailable")
            case .failed:
                notice("share.failed")
            case .off, .starting:
                ProgressView().tint(Palette.textSecondary)
            }
            Spacer(minLength: 0)
            Button("share.stop") {
                link.stop()
                dismiss()
            }
            .buttonStyle(.primaryPill)
        }
        .padding(Space.lg)
        .padding(.top, Space.lg)
        .background(Palette.background.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }

    private func notice(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .textStyle(.body)
            .foregroundStyle(Palette.textSecondary)
            .multilineTextAlignment(.center)
    }

    private static func qrCode(for url: URL) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(url.absoluteString.utf8)
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: codeScale, y: codeScale)),
              let image = CIContext().createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: image)
    }
}
