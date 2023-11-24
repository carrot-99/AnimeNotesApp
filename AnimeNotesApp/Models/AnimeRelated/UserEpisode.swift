//  UserEpisode.swift

import Foundation

// MARK: - episodesHistory構造体
struct UserEpisode: Codable, Identifiable, Equatable {
    var id: String
    var user_id: String
    var anime_id: Int
    var episode_num: Int
    var status: Int
}

extension UserEpisode {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "user_id": user_id,
            "anime_id": anime_id,
            "episode_num": episode_num,
            "status": status
        ]
    }
}
