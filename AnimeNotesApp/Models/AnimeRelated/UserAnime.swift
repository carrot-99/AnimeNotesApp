//  UserAnime.swift

import Foundation

/// `userWatchingHistory` コレクションのドキュメント（ユーザーごとの作品の視聴状況）
struct UserAnime: Codable, Identifiable, Hashable {
    var id: String
    var user_id: String
    var anime_id: Int
    var title: String
    var episodes: Int?
    var season: String?
    var seasonYear: Int?
    var status: Int
}

extension UserAnime {
    /// 未ログインユーザー用の仮ユーザー ID
    static let guestUserId = "local"

    static func documentId(userId: String, animeId: Int) -> String {
        "\(userId)-\(animeId)"
    }

    init(anime: Anime, animeId: Int, userId: String, status: WatchStatus = .notWatched) {
        self.init(
            id: UserAnime.documentId(userId: userId, animeId: animeId),
            user_id: userId,
            anime_id: animeId,
            title: anime.title.native,
            episodes: anime.episodes,
            season: anime.season,
            seasonYear: anime.seasonYear,
            status: status.rawValue
        )
    }

    var watchStatus: WatchStatus {
        get { WatchStatus(storedValue: status) }
        set { status = newValue.rawValue }
    }

    var seasonText: String {
        AnimeSeason.label(year: seasonYear, season: season)
    }

    var episodesText: String {
        guard let episodes, episodes > 0 else { return "話数未定" }
        return "全\(episodes)話"
    }

    /// 作品一覧と視聴履歴を突き合わせる。履歴がない作品は「未視聴」として扱う（Firestore には書き込まない）。
    static func merge(animes: [Anime], history: [UserAnime], userId: String) -> [UserAnime] {
        let historyById = Dictionary(history.map { ($0.anime_id, $0) }, uniquingKeysWith: { first, _ in first })
        return animes.compactMap { anime in
            guard let animeId = anime.animeId else { return nil }
            var userAnime = UserAnime(anime: anime, animeId: animeId, userId: userId)
            if let record = historyById[animeId] {
                userAnime.status = record.status
            }
            return userAnime
        }
    }
}

extension Array where Element == UserAnime {
    func sortedByTitle() -> [UserAnime] {
        sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }
}
