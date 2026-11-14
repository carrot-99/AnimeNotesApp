//  AnimeNotesAppTests.swift

import XCTest
@testable import AnimeNotesApp

final class AnimeSeasonTests: XCTestCase {
    private func date(_ year: Int, _ month: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return calendar.date(from: DateComponents(year: year, month: month, day: 15))!
    }

    func testCurrentSeasonFollowsBroadcastQuarters() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        XCTAssertEqual(AnimeSeason.current(date: date(2026, 1), calendar: calendar), AnimeSeason(year: 2026, quarter: .winter))
        XCTAssertEqual(AnimeSeason.current(date: date(2026, 4), calendar: calendar), AnimeSeason(year: 2026, quarter: .spring))
        XCTAssertEqual(AnimeSeason.current(date: date(2026, 9), calendar: calendar), AnimeSeason(year: 2026, quarter: .summer))
        XCTAssertEqual(AnimeSeason.current(date: date(2026, 11), calendar: calendar), AnimeSeason(year: 2026, quarter: .fall))
    }

    func testNextSeasonWrapsToNextYear() {
        XCTAssertEqual(AnimeSeason(year: 2026, quarter: .fall).next, AnimeSeason(year: 2027, quarter: .winter))
        XCTAssertEqual(AnimeSeason(year: 2026, quarter: .spring).next, AnimeSeason(year: 2026, quarter: .summer))
    }

    func testGroupedByYearIsNewestFirstAndStopsAtLatest() {
        let groups = AnimeSeason.groupedByYear(through: AnimeSeason(year: 2027, quarter: .winter))
        XCTAssertEqual(groups.first?.year, 2027)
        XCTAssertEqual(groups.first?.seasons, [AnimeSeason(year: 2027, quarter: .winter)])
        XCTAssertEqual(groups.last?.year, AnimeSeason.firstYear)
        XCTAssertEqual(groups[1].seasons.count, 4)
    }

    func testLabelFromStoredValues() {
        XCTAssertEqual(AnimeSeason.label(year: 2023, season: "FALL"), "2023年秋")
        XCTAssertEqual(AnimeSeason.label(year: 2023, season: nil), "2023年")
        XCTAssertEqual(AnimeSeason.label(year: nil, season: "FALL"), "放送時期不明")
    }
}

final class WatchStatusTests: XCTestCase {
    func testStoredValuesMatchExistingFirestoreData() {
        XCTAssertEqual(WatchStatus.notWatched.rawValue, 0)
        XCTAssertEqual(WatchStatus.watching.rawValue, 1)
        XCTAssertEqual(WatchStatus.onHold.rawValue, 2)
        XCTAssertEqual(WatchStatus.watched.rawValue, 3)
        XCTAssertEqual(WatchStatus.planned.rawValue, 4)
    }

    func testUnknownStoredValueFallsBackToNotWatched() {
        XCTAssertEqual(WatchStatus(storedValue: 99), .notWatched)
    }
}

final class UserAnimeMergeTests: XCTestCase {
    private func anime(_ id: String, _ title: String) -> Anime {
        var anime = Anime(title: .init(native: title), seasonYear: 2024, season: "SPRING", episodes: 12)
        anime.id = id
        return anime
    }

    func testMergeAppliesHistoryAndDefaultsToNotWatched() {
        let animes = [anime("1", "A"), anime("2", "B")]
        var record = UserAnime(anime: animes[1], animeId: 2, userId: "u")
        record.watchStatus = .watching

        let merged = UserAnime.merge(animes: animes, history: [record], userId: "u")

        XCTAssertEqual(merged.map(\.anime_id), [1, 2])
        XCTAssertEqual(merged[0].watchStatus, .notWatched)
        XCTAssertEqual(merged[1].watchStatus, .watching)
        XCTAssertEqual(merged[0].id, "u-1")
    }

    func testMergeSkipsAnimesWithoutNumericId() {
        let merged = UserAnime.merge(animes: [anime("abc", "X")], history: [], userId: "u")
        XCTAssertTrue(merged.isEmpty)
    }

    func testEpisodesText() {
        let base = UserAnime(anime: anime("1", "A"), animeId: 1, userId: "u")
        XCTAssertEqual(base.episodesText, "全12話")
        var unknown = base
        unknown.episodes = nil
        XCTAssertEqual(unknown.episodesText, "話数未定")
    }
}

final class ValidationTests: XCTestCase {
    func testEmail() {
        XCTAssertTrue(Validation.isValidEmail("user@example.com"))
        XCTAssertFalse(Validation.isValidEmail("user@example"))
        XCTAssertFalse(Validation.isValidEmail("user@example.com extra"))
    }

    func testPassword() {
        XCTAssertTrue(Validation.isValidPassword("abcd1234"))
        XCTAssertFalse(Validation.isValidPassword("abcdefgh"))
        XCTAssertFalse(Validation.isValidPassword("12345678"))
        XCTAssertFalse(Validation.isValidPassword("abc123"))
    }

    func testUsername() {
        XCTAssertTrue(Validation.isValidUsername("アニメ好き"))
        XCTAssertFalse(Validation.isValidUsername("   "))
        XCTAssertFalse(Validation.isValidUsername(String(repeating: "a", count: 21)))
    }
}

final class ChunkTests: XCTestCase {
    func testChunked() {
        XCTAssertEqual(Array(1...7).chunked(into: 3), [[1, 2, 3], [4, 5, 6], [7]])
        XCTAssertEqual([Int]().chunked(into: 3), [])
    }
}
