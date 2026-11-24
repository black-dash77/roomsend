import SwiftUI

/// A device's avatar: its `IdentityPattern` drawn in a circle, with the device type as a small
/// badge, the way a token logo carries its network on Revolut and MetaMask.
struct IdentityAvatar: View {
    let size: CGFloat
    let deviceType: DeviceType?
    private let pattern: IdentityPattern

    private static let badgeRing: CGFloat = 2

    init(fingerprint: String, size: CGFloat, deviceType: DeviceType? = nil) {
        self.size = size
        self.deviceType = deviceType
        pattern = IdentityPattern(fingerprint: fingerprint)
    }

    var body: some View {
        Canvas { context, canvasSize in
            draw(in: &context, side: min(canvasSize.width, canvasSize.height))
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(alignment: .bottomTrailing) { badge }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var badge: some View {
        if let deviceType {
            Image(systemName: deviceType.symbolName)
                .font(.system(size: Size.badgeIcon, weight: .bold))
                .foregroundStyle(Palette.actionLabel)
                .frame(width: Size.badge, height: Size.badge)
                .background(Palette.actionFill, in: Circle())
                .overlay { Circle().stroke(Palette.block, lineWidth: Self.badgeRing) }
                .offset(x: Self.badgeRing, y: Self.badgeRing)
        }
    }

    private func draw(in context: inout GraphicsContext, side: CGFloat) {
        let bounds = CGRect(x: 0, y: 0, width: side, height: side)
        context.fill(Path(bounds), with: .color(IdentityPalette.color(at: pattern.baseColorIndex)))
        for shape in pattern.shapes {
            var layer = context
            layer.translateBy(x: bounds.midX + shape.offsetX * side, y: bounds.midY + shape.offsetY * side)
            layer.rotate(by: .degrees(shape.rotation))
            let length = side * IdentityPattern.shapeScale
            let square = CGRect(x: -length / 2, y: -length / 2, width: length, height: length)
            layer.fill(Path(square), with: .color(IdentityPalette.color(at: shape.colorIndex)))
        }
    }
}
