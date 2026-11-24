import SwiftUI

/// The review of a send: the object at the center, who receives, the details, two pills.
struct SendSheet: View {
    @Environment(SendFlow.self) private var flow
    @Environment(DiscoveryService.self) private var discovery
    @Environment(IdentityStore.self) private var identity
    @Environment(HistoryStore.self) private var history
    @Environment(NetworkSettings.self) private var network
    @Environment(ShareLink.self) private var link
    @FocusState private var isTypingPin: Bool
    @State private var isSharingLink = false

    var body: some View {
        @Bindable var flow = flow
        VStack(spacing: Space.xxl) {
            let summary = SendSummary(items: flow.items)
            SendObject(summary: summary, status: flow.phase.objectStatus, caption: flow.phase.caption(for: summary))
                .padding(.top, Space.huge)
            recipients(selection: $flow.recipientID)
            if case .needsPin = flow.phase { pinField(text: $flow.pin) } else { details }
            Spacer(minLength: 0)
            actions
        }
        .padding(.horizontal, Space.lg)
        .padding(.bottom, Space.sm)
        .background(Palette.background.ignoresSafeArea())
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(isSending)
        .onChange(of: discovery.devices) { _, devices in flow.pickDefaultRecipient(among: devices) }
        .sheet(isPresented: $isSharingLink) { ShareLinkSheet() }
    }

    private var targets: [NearbyDevice] { flow.recipients(among: discovery.devices) }

    private var isSending: Bool {
        if case .sending = flow.phase { return true }
        return false
    }

    @ViewBuilder
    private func recipients(selection: Binding<NearbyDevice.ID?>) -> some View {
        if discovery.devices.isEmpty {
            Text("send.noRecipient")
                .textStyle(.body)
                .foregroundStyle(Palette.textSecondary)
                .multilineTextAlignment(.center)
                .frame(height: Size.carouselHeight)
        } else {
            RecipientCarousel(devices: discovery.devices, selection: selection)
                .disabled(flow.phase != .reviewing)
        }
    }

    private var details: some View {
        Block {
            ValueRow(key: "send.size", value: Text(verbatim: SendSummary(items: flow.items).size))
            if let first = targets.first, targets.count == 1 {
                ValueRow(key: "send.security", value: Text(first.transport == .https ? "send.security.https" : "send.security.http"))
            } else if targets.count > 1 {
                ValueRow(key: "send.to", value: Text("send.devices \(targets.count)"))
            }
        }
    }

    private func pinField(text: Binding<String>) -> some View {
        Block(label: "send.pin.label") {
            TextField("send.pin.placeholder", text: text)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .textStyle(.object)
                .foregroundStyle(Palette.textPrimary)
                .focused($isTypingPin)
                .onAppear { isTypingPin = true }
        }
    }

    @ViewBuilder
    private var actions: some View {
        switch flow.phase {
        case .reviewing, .needsPin:
            VStack(spacing: Space.sm) {
                Button("share.action", systemImage: "link", action: shareByLink)
                    .textStyle(.rowTitle)
                    .foregroundStyle(Palette.textPrimary)
                    .frame(minHeight: Size.touch)
                HStack(spacing: Space.sm) {
                    Button("send.cancel") { flow.close() }.buttonStyle(.secondaryPill)
                    Button("send.action", action: send).buttonStyle(.primaryPill).disabled(targets.isEmpty)
                }
            }
        case .sending:
            Button("send.stop") { flow.cancel() }.buttonStyle(.secondaryPill)
        case .sent:
            Button("send.done.action") { flow.close() }.buttonStyle(.primaryPill)
        case .failed:
            HStack(spacing: Space.sm) {
                Button("send.cancel") { flow.close() }.buttonStyle(.secondaryPill)
                Button("send.retry") { flow.retry() }.buttonStyle(.primaryPill)
            }
        }
    }

    private func shareByLink() {
        link.start(flow.items, owner: identity.identity.alias)
        isSharingLink = true
    }

    private func send() {
        flow.send(to: targets, sender: identity.info(network: network, announce: nil), history: history)
    }
}
