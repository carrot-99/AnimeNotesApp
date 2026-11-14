//  WatchStatus.swift

import SwiftUI

/// 作品・エピソードの視聴状況。Firestore には `rawValue`（Int）で保存される。
enum WatchStatus: Int, CaseIterable, Identifiable {
    case notWatched = 0
    case watching = 1
    case onHold = 2
    case watched = 3
    case planned = 4

    var id: Int { rawValue }

    /// 保存値から生成する。未知の値は未視聴として扱う。
    init(storedValue: Int) {
        self = WatchStatus(rawValue: storedValue) ?? .notWatched
    }

    /// メニューに並べる順番（視聴の流れに沿った順）
    static let menuOrder: [WatchStatus] = [.planned, .watching, .onHold, .watched, .notWatched]

    /// ホーム画面で集計するステータス
    static let tracked: [WatchStatus] = [.watching, .planned, .onHold, .watched]

    var label: String {
        switch self {
        case .notWatched: return "未視聴"
        case .watching: return "視聴中"
        case .onHold: return "視聴中断"
        case .watched: return "視聴済"
        case .planned: return "視聴予定"
        }
    }

    /// 一覧画面のタイトル
    var listTitle: String { "\(label)の作品" }

    var systemImage: String {
        switch self {
        case .notWatched: return "circle"
        case .watching: return "play.circle.fill"
        case .onHold: return "pause.circle.fill"
        case .watched: return "checkmark.circle.fill"
        case .planned: return "calendar.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .notWatched: return .secondary
        case .watching: return .blue
        case .onHold: return .orange
        case .watched: return .green
        case .planned: return .purple
        }
    }
}
