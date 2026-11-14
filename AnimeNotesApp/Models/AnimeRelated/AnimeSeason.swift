//  AnimeSeason.swift

import Foundation

/// 放送クール（年 + 季節）
struct AnimeSeason: Hashable, Identifiable, Comparable {
    enum Quarter: String, CaseIterable {
        // Firestore（AniList）の season 値と一致させる
        case winter = "WINTER"
        case spring = "SPRING"
        case summer = "SUMMER"
        case fall = "FALL"

        init(month: Int) {
            switch month {
            case 1...3: self = .winter
            case 4...6: self = .spring
            case 7...9: self = .summer
            default: self = .fall
            }
        }

        /// Firestore に保存されている文字列から生成する
        init?(storedValue: String?) {
            guard let value = storedValue?.uppercased() else { return nil }
            self.init(rawValue: value)
        }

        var label: String {
            switch self {
            case .winter: return "冬"
            case .spring: return "春"
            case .summer: return "夏"
            case .fall: return "秋"
            }
        }

        var systemImage: String {
            switch self {
            case .winter: return "snowflake"
            case .spring: return "leaf"
            case .summer: return "sun.max"
            case .fall: return "wind"
            }
        }

        var order: Int { Quarter.allCases.firstIndex(of: self) ?? 0 }
    }

    /// 一覧に表示する最古の年
    static let firstYear = 1940

    let year: Int
    let quarter: Quarter

    var id: String { "\(year)-\(quarter.rawValue)" }

    /// 例: "2024年春"
    var displayName: String { "\(year)年\(quarter.label)" }

    var next: AnimeSeason {
        let all = Quarter.allCases
        if quarter.order == all.count - 1 {
            return AnimeSeason(year: year + 1, quarter: all[0])
        }
        return AnimeSeason(year: year, quarter: all[quarter.order + 1])
    }

    static func current(date: Date = Date(), calendar: Calendar = .current) -> AnimeSeason {
        let components = calendar.dateComponents([.year, .month], from: date)
        return AnimeSeason(year: components.year ?? 2000, quarter: Quarter(month: components.month ?? 1))
    }

    /// `latest` から `firstYear` までのクールを年ごとに新しい順でまとめる
    static func groupedByYear(through latest: AnimeSeason) -> [(year: Int, seasons: [AnimeSeason])] {
        guard latest.year >= firstYear else { return [] }
        return (firstYear...latest.year).reversed().map { year in
            let seasons = Quarter.allCases
                .map { AnimeSeason(year: year, quarter: $0) }
                .filter { $0 <= latest }
            return (year, seasons)
        }
    }

    static func < (lhs: AnimeSeason, rhs: AnimeSeason) -> Bool {
        if lhs.year != rhs.year { return lhs.year < rhs.year }
        return lhs.quarter.order < rhs.quarter.order
    }

    /// Firestore の値（seasonYear / season）を表示用文字列に変換する
    static func label(year: Int?, season: String?) -> String {
        switch (year, Quarter(storedValue: season)) {
        case let (year?, quarter?): return "\(year)年\(quarter.label)"
        case let (year?, nil): return "\(year)年"
        default: return "放送時期不明"
        }
    }
}
