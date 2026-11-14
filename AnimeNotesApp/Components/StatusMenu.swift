//  StatusMenu.swift

import SwiftUI

/// 視聴状況のアイコン
struct StatusIcon: View {
    let status: WatchStatus
    var font: Font = .title2

    var body: some View {
        Image(systemName: status.systemImage)
            .font(font)
            .foregroundColor(status.color)
            .accessibilityLabel(Text(status.label))
    }
}

/// 視聴状況の選択肢（Menu / contextMenu 共通）
struct StatusMenuItems: View {
    let current: WatchStatus
    let onSelect: (WatchStatus) -> Void

    var body: some View {
        ForEach(WatchStatus.menuOrder) { status in
            Button {
                onSelect(status)
            } label: {
                Label(status.label, systemImage: status == current ? "checkmark" : status.systemImage)
            }
        }
    }
}

/// アイコンをタップして視聴状況を変更するメニュー
struct StatusMenu: View {
    let status: WatchStatus
    let onSelect: (WatchStatus) -> Void

    var body: some View {
        Menu {
            StatusMenuItems(current: status, onSelect: onSelect)
        } label: {
            StatusIcon(status: status)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .accessibilityHint(Text("視聴状況を変更"))
    }
}
