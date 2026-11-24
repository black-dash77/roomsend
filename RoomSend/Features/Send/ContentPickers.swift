import PhotosUI
import SwiftUI
import UIKit

/// Presents the picker of the requested source and hands back what was picked, as items ready
/// to send. « Paste » needs no picker: the clipboard becomes an item at once.
struct ContentPickers: ViewModifier {
    @Binding var source: ContentSource?
    let onItems: ([OutgoingItem]) -> Void

    @State private var photoSelection: [PhotosPickerItem] = []
    /// The message typed, handed over once its sheet is gone: the review cannot open over it.
    @State private var composedItems: [OutgoingItem] = []

    func body(content: Content) -> some View {
        content
            .photosPicker(isPresented: isPresenting(.photos), selection: $photoSelection, matching: .any(of: [.images, .videos]))
            .fileImporter(isPresented: isPresenting(.files), allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
                handle(result)
            }
            .sheet(isPresented: isPresenting(.text), onDismiss: handOverComposedItems) {
                TextComposer { text in composedItems = [ItemLoader.item(fromText: text)].compactMap { $0 } }
            }
            .onChange(of: photoSelection) { _, selection in load(selection) }
            .onChange(of: source) { _, newSource in
                if newSource == .paste { paste() }
            }
    }

    private func isPresenting(_ target: ContentSource) -> Binding<Bool> {
        Binding(
            get: { source == target },
            set: { isShown in if !isShown, source == target { source = nil } }
        )
    }

    private func load(_ selection: [PhotosPickerItem]) {
        guard !selection.isEmpty else { return }
        Task {
            let items = await ItemLoader.items(from: selection)
            photoSelection = []
            onItems(items)
        }
    }

    private func handle(_ result: Result<[URL], any Error>) {
        switch result {
        case let .success(urls):
            onItems(ItemLoader.items(from: urls))
        case let .failure(error):
            Log.content.error("File picker failed: \(error.localizedDescription)")
        }
    }

    private func handOverComposedItems() {
        guard !composedItems.isEmpty else { return }
        let items = composedItems
        composedItems = []
        onItems(items)
    }

    private func paste() {
        source = nil
        guard let text = UIPasteboard.general.string, let item = ItemLoader.item(fromText: text) else { return }
        onItems([item])
    }
}

extension View {
    func contentPickers(source: Binding<ContentSource?>, onItems: @escaping ([OutgoingItem]) -> Void) -> some View {
        modifier(ContentPickers(source: source, onItems: onItems))
    }
}
