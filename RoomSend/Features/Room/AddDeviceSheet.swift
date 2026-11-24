import SwiftUI
import UIKit

/// Adding by hand, both ways: this device's own address at the top, for the other person to
/// type, and the field for theirs. Two people open the same window and read each other.
struct AddDeviceSheet: View {
    @Environment(DiscoveryService.self) private var discovery
    @Environment(FavoritesStore.self) private var favorites
    @Environment(NetworkSettings.self) private var network
    @Environment(\.dismiss) private var dismiss

    @State private var address = ""
    @State private var isSearching = false
    @State private var isNotFound = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            Text("add.title")
                .textStyle(.screenTitle)
                .foregroundStyle(Palette.textPrimary)
            OwnAddressBlock(port: Int(network.port))
            theirAddress
            Spacer(minLength: 0)
            Button(isSearching ? "add.searching" : "add.action", action: search)
                .buttonStyle(.primaryPill)
                .disabled(isSearching || ManualAddress(address) == nil)
        }
        .padding(Space.lg)
        .padding(.top, Space.lg)
        .background(Palette.background.ignoresSafeArea())
        .presentationDragIndicator(.visible)
        .onAppear { isFocused = true }
        .onChange(of: address) { isNotFound = false }
    }

    private var theirAddress: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Text("add.theirs")
                .textStyle(.label)
                .foregroundStyle(Palette.textSecondary)
            TextField("add.placeholder", text: $address)
                .keyboardType(.numbersAndPunctuation)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .textStyle(.object)
                .foregroundStyle(Palette.textPrimary)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(search)
            Text(isNotFound ? "add.notFound" : "add.detail")
                .textStyle(.body)
                .foregroundStyle(isNotFound ? Palette.danger : Palette.textSecondary)
        }
    }

    private func search() {
        guard let target = ManualAddress(address), !isSearching else { return }
        isSearching = true
        Task {
            let device = await discovery.probe(target)
            isSearching = false
            guard let device else { return isNotFound = true }
            if !favorites.contains(device.id) { favorites.toggle(device) }
            dismiss()
        }
    }
}

/// This device's address on the Wi-Fi, with Copy: what the other person types to add it.
private struct OwnAddressBlock: View {
    let port: Int

    @State private var host = LocalAddress.wifiIPv4()
    @State private var isCopied = false

    var body: some View {
        Block(label: "add.yours") {
            if let host {
                let text = ManualAddress.display(host: host, port: port)
                HStack(spacing: Space.md) {
                    Text(verbatim: text)
                        .textStyle(.title)
                        .monospacedDigit()
                        .foregroundStyle(Palette.textPrimary)
                        .textSelection(.enabled)
                    Spacer(minLength: Space.sm)
                    Button { copy(text) } label: {
                        IconRound(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("receive.copy"))
                }
                Text("add.yours.detail")
                    .textStyle(.meta)
                    .foregroundStyle(Palette.textSecondary)
            } else {
                Text("add.yours.none")
                    .textStyle(.meta)
                    .foregroundStyle(Palette.textSecondary)
            }
        }
    }

    private func copy(_ text: String) {
        UIPasteboard.general.string = text
        withAnimation(Motion.quick) { isCopied = true }
    }
}
