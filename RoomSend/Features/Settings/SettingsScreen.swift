import SwiftUI

/// How the others see this device, how it receives, how it shows itself on the Wi-Fi.
struct SettingsScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl) {
                Text("settings.title")
                    .textStyle(.screenTitle)
                    .foregroundStyle(Palette.textPrimary)
                IdentitySection()
                ReceiveSection()
                AppearanceSection()
                LanguageSection()
                NetworkSection()
                AboutSection()
            }
            .padding(.horizontal, Space.lg)
            .padding(.top, Space.lg)
            .padding(.bottom, Space.huge)
        }
        .scrollIndicators(.hidden)
        .statusBarScrim()
        .background(Palette.background.ignoresSafeArea())
    }
}

/// A switch with its title and one line saying what it changes.
struct SettingToggle: View {
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: Space.xxs) {
                Text(title).textStyle(.rowTitle).foregroundStyle(Palette.textPrimary)
                Text(detail).textStyle(.meta).foregroundStyle(Palette.textSecondary)
            }
        }
        .tint(Palette.live)
    }
}

private struct IdentitySection: View {
    @Environment(IdentityStore.self) private var identity
    @State private var draft = ""
    @FocusState private var isEditing: Bool

    var body: some View {
        Block {
            HStack(spacing: Space.lg) {
                IdentityAvatar(fingerprint: identity.identity.fingerprint, size: Size.settingsAvatar, deviceType: .mobile)
                VStack(alignment: .leading, spacing: Space.xxs) {
                    TextField("settings.name.placeholder", text: $draft)
                        .textStyle(.title)
                        .foregroundStyle(Palette.textPrimary)
                        .focused($isEditing)
                        .submitLabel(.done)
                        .onSubmit { identity.rename(draft) }
                    Text("settings.identity.detail").textStyle(.meta).foregroundStyle(Palette.textSecondary)
                }
                Spacer(minLength: Space.sm)
                Button { withAnimation(Motion.settle) { identity.shuffleAlias() } } label: {
                    Image(systemName: "shuffle")
                        .font(.system(size: Size.rowIcon, weight: .semibold))
                        .foregroundStyle(Palette.textPrimary)
                        .frame(width: Size.touch, height: Size.touch)
                }
                .glassEffect(.regular.interactive(), in: Circle())
                .accessibilityLabel(Text("room.identity.shuffle"))
            }
        }
        .onAppear { draft = identity.identity.alias }
        .onChange(of: identity.identity.alias) { _, alias in if !isEditing { draft = alias } }
        .onChange(of: isEditing) { _, editing in if !editing { identity.rename(draft) } }
    }
}

private struct ReceiveSection: View {
    @Environment(ReceiveSettings.self) private var settings
    @Environment(DiscoveryService.self) private var discovery

    var body: some View {
        @Bindable var settings = settings
        @Bindable var discovery = discovery
        Block(label: "settings.receive") {
            SettingToggle(title: "settings.visible", detail: "settings.visible.detail", isOn: $discovery.isVisible)
            SettingToggle(title: "settings.quickSave", detail: "settings.quickSave.detail", isOn: $settings.acceptsAutomatically)
            SettingToggle(title: "settings.photos", detail: "settings.photos.detail", isOn: $settings.savesMediaToPhotos)
            SettingToggle(title: "settings.pin", detail: "settings.pin.detail", isOn: $settings.requiresPin)
            if settings.requiresPin {
                ValueRow(key: "settings.pin.code", value: Text(verbatim: settings.pin).monospacedDigit())
            }
        }
    }
}

private struct AppearanceSection: View {
    @AppStorage(Appearance.storageKey) private var appearance = Appearance.system

    var body: some View {
        Block(label: "settings.appearance") {
            Picker("settings.appearance", selection: $appearance) {
                ForEach(Appearance.allCases) { mode in Text(mode.title).tag(mode) }
            }
            .pickerStyle(.segmented)
        }
    }
}
