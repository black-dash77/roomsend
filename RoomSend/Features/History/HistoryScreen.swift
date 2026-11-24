import SwiftUI

/// What left this device, newest first: who received it, what, when.
struct HistoryScreen: View {
    @Environment(HistoryStore.self) private var history

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            Text("history.title")
                .textStyle(.screenTitle)
                .foregroundStyle(Palette.textPrimary)
            if history.records.isEmpty {
                Block {
                    BlockRow(
                        title: Text("history.empty.title"),
                        detail: Text("history.empty.detail"),
                        leading: { IconRound(systemName: "clock.arrow.circlepath") },
                        trailing: { EmptyView() }
                    )
                }
            } else {
                ScrollView {
                    Block {
                        ForEach(history.records) { record in HistoryRow(record: record) }
                    }
                }
                .scrollIndicators(.hidden)
                .statusBarScrim()
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Space.lg)
        .padding(.top, Space.lg)
        .background(Palette.background.ignoresSafeArea())
    }
}

private struct HistoryRow: View {
    let record: TransferRecord

    var body: some View {
        let summary = SendSummary(record: record)
        let date = record.date.formatted(.dateTime.day().month().hour().minute())
        BlockRow(
            title: Text(verbatim: record.peerAlias),
            detail: record.direction == .sent ? Text("history.sent \(date)") : Text("history.received \(date)"),
            leading: {
                IdentityAvatar(fingerprint: record.peerFingerprint, size: Size.rowAvatar, deviceType: record.peerType)
            },
            trailing: {
                VStack(alignment: .trailing, spacing: Space.xxs) {
                    Text(verbatim: summary.title)
                        .textStyle(.rowTitle)
                        .foregroundStyle(Palette.textPrimary)
                    Text(verbatim: summary.size)
                        .textStyle(.meta)
                        .foregroundStyle(Palette.textSecondary)
                }
            }
        )
        .accessibilityElement(children: .combine)
    }
}
