import SwiftUI

/// Encryption, port and the address-by-address search; any change restarts the network.
struct NetworkSection: View {
    @Environment(NetworkSettings.self) private var network
    @Environment(AppModel.self) private var model
    @State private var portText = ""

    var body: some View {
        @Bindable var network = network
        Block(label: "settings.network") {
            SettingToggle(title: "settings.encryption", detail: "settings.encryption.detail", isOn: $network.isEncrypted)
                .disabled(!model.canEncrypt)
            SettingToggle(title: "settings.scan", detail: "settings.scan.detail", isOn: $network.isFallbackScanEnabled)
            HStack {
                Text("settings.port").textStyle(.body).foregroundStyle(Palette.textSecondary)
                Spacer(minLength: Space.md)
                TextField(String(LocalSendProtocol.port), text: $portText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .textStyle(.body)
                    .foregroundStyle(Palette.textPrimary)
                    .onSubmit(applyPort)
            }
        }
        .onAppear { portText = String(network.port) }
        .onChange(of: network.isEncrypted) { model.restartNetwork() }
        .onChange(of: portText) { _, text in if UInt16(text) != nil, text.count >= Self.minPortDigits { applyPort() } }
    }

    private static let minPortDigits = 4

    private func applyPort() {
        guard let port = UInt16(portText), port > 0, port != network.port else { return }
        network.port = port
        model.restartNetwork()
    }
}
