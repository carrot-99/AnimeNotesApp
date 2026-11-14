//  UserEpisode.swift

import Foundation

/// `userWatchingHistory/{id}/episodesHistory` のドキュメント（エピソードごとの視聴状況）
struct UserEpisode: Codable, Identifiable, Hashable {
    var id: String
    var user_id: String
    var anime_id: Int
    var episode_num: Int
    var status: Int
}

extension UserEpisode {
    static func documentId(userId: String, animeId: Int, episodeNumber: Int) -> String {
        "\(userId)-\(animeId)-\(episodeNumber)"
    }

    init(userId: String, animeId: Int, episodeNumber: Int, status: WatchStatus = .notWatched) {
        self.init(
            id: UserEpisode.documentId(userId: userId, animeId: animeId, episodeNumber: episodeNumber),
            user_id: userId,
            anime_id: animeId,
            episode_num: episodeNumber,
            status: status.rawValue
        )
    }

    var watchStatus: WatchStatus {
        get { WatchStatus(storedValue: status) }
        set { status = newValue.rawValue }
    }
}
