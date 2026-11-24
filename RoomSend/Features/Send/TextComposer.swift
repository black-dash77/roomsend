import SwiftUI

/// A message to send: the text field takes the screen, « Next » sits under the thumb.
struct TextComposer: View {
    let onDone: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            Text("text.title")
                .textStyle(.screenTitle)
                .foregroundStyle(Palette.textPrimary)
            TextField("text.placeholder", text: $text, axis: .vertical)
                .textStyle(.title)
                .foregroundStyle(Palette.textPrimary)
                .focused($isFocused)
                .frame(maxHeight: .infinity, alignment: .top)
            Button("text.next") {
                onDone(text)
                dismiss()
            }
            .buttonStyle(.primaryPill)
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(Space.lg)
        .padding(.top, Space.lg)
        .background(Palette.background.ignoresSafeArea())
        .presentationDragIndicator(.visible)
        .onAppear { isFocused = true }
    }
}
