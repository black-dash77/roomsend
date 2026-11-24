import SwiftUI

@main
struct RoomSendApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model.identity)
                .environment(model.network)
                .environment(model.discovery)
                .environment(model.history)
                .environment(model.flow)
                .environment(model.receiveSettings)
                .environment(model.receiver)
                .environment(model.server)
                .environment(model.favorites)
                .environment(model.shareLink)
                .environment(model.language)
                .environment(model)
        }
    }
}

/// The three places of the app, in Apple's tab bar. Discovery and the server run while the app
/// is in front; an arriving transfer opens its sheet over whatever is on screen.
struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(SendFlow.self) private var flow
    @Environment(ReceiveCoordinator.self) private var receiver
    @Environment(LanguageSettings.self) private var language
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(Appearance.storageKey) private var appearance = Appearance.system

    var body: some View {
        @Bindable var flow = flow
        TabView {
            Tab("tab.room", systemImage: "dot.radiowaves.left.and.right") { RoomScreen() }
            Tab("tab.history", systemImage: "clock.arrow.circlepath") { HistoryScreen() }
            Tab("tab.settings", systemImage: "gearshape") { SettingsScreen() }
        }
        .tint(Palette.textPrimary)
        .preferredColorScheme(appearance.colorScheme)
        .sheet(isPresented: $flow.isPresented, onDismiss: { flow.close() }) { SendSheet() }
        .sheet(isPresented: incomingBinding) { IncomingSheet() }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active { model.goOnline(); model.openSharedItems() } else if phase == .background { model.goOffline() }
        }
        .environment(\.locale, language.locale)
    }

    private var incomingBinding: Binding<Bool> {
        Binding(
            get: { receiver.phase != .idle },
            set: { isShown in if !isShown { receiver.dismiss() } }
        )
    }
}
