//  AnimeDataService.swift

import FirebaseFirestore

final class AnimeDataService: FirestoreService, AnimeDataServiceProtocol {
    private var animes: CollectionReference { db.collection(FirestoreCollection.animes) }
    private var history: CollectionReference { db.collection(FirestoreCollection.watchingHistory) }

    func fetchAnimes(in season: AnimeSeason) async throws -> [Anime] {
        let query = animes
            .whereField("seasonYear", isEqualTo: season.year)
            .whereField("season", isEqualTo: season.quarter.rawValue)
        return try await documents(query, as: Anime.self)
    }

    func searchAnimes(title: String) async throws -> [Anime] {
        let keyword = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return [] }
        let query = animes
            .whereField("title.native", isGreaterThanOrEqualTo: keyword)
            .whereField("title.native", isLessThanOrEqualTo: keyword + "\u{f8ff}")
            .limit(to: 100)
        return try await documents(query, as: Anime.self)
    }

    func fetchHistory(userId: String, animeIds: [Int]) async throws -> [UserAnime] {
        let chunks = Array(Set(animeIds)).chunked(into: Self.inQueryLimit)
        return try await withThrowingTaskGroup(of: [UserAnime].self) { group in
            for ids in chunks where !ids.isEmpty {
                let query = history
                    .whereField("user_id", isEqualTo: userId)
                    .whereField("anime_id", in: ids)
                group.addTask { try await self.documents(query, as: UserAnime.self) }
            }
            var results: [UserAnime] = []
            for try await chunk in group {
                results += chunk
            }
            return results
        }
    }

    func fetchHistory(userId: String, status: WatchStatus) async throws -> [UserAnime] {
        let query = history
            .whereField("user_id", isEqualTo: userId)
            .whereField("status", isEqualTo: status.rawValue)
        return try await documents(query, as: UserAnime.self)
    }

    func fetchStatusCounts(userId: String) async throws -> [WatchStatus: Int] {
        try await withThrowingTaskGroup(of: (WatchStatus, Int).self) { group in
            for status in WatchStatus.tracked {
                let query = history
                    .whereField("user_id", isEqualTo: userId)
                    .whereField("status", isEqualTo: status.rawValue)
                group.addTask {
                    let snapshot = try await query.count.getAggregation(source: .server)
                    return (status, snapshot.count.intValue)
                }
            }
            var counts: [WatchStatus: Int] = [:]
            for try await (status, count) in group {
                counts[status] = count
            }
            return counts
        }
    }

    func save(_ anime: UserAnime) async throws {
        try await set(anime, at: history.document(anime.id), merge: true)
    }
}
