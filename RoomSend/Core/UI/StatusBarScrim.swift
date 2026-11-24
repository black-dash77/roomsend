import SwiftUI

/// Keeps scrolling content from running into the clock: the status bar sits on the screen's own
/// background, and the content fades out just below it. Without a navigation bar, iOS draws no
/// scroll edge effect there.
private struct StatusBarScrim: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 0)
                    .background(Palette.background.ignoresSafeArea(edges: .top))
                LinearGradient(colors: [Palette.background, Palette.background.opacity(0)], startPoint: .top, endPoint: .bottom)
                    .frame(height: Space.lg)
            }
            .allowsHitTesting(false)
        }
    }
}

extension View {
    func statusBarScrim() -> some View {
        modifier(StatusBarScrim())
    }
}
