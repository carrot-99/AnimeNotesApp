//  UserAnime.swift

import Foundation

// MARK: - userWatchingHistory構造体
struct UserAnime: Codable, Identifiable, Equatable {
    var id: String
    var user_id: String
    var anime_id: Int
    var title: String
    var episodes: Int?
    var season: String?
    var seasonYear: Int?
    var status: Int

    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case anime_id
        case title
        case episodes
        case season
        case seasonYear
        case status
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(user_id, forKey: .user_id)
        try container.encode(anime_id, forKey: .anime_id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(episodes, forKey: .episodes)
        try container.encodeIfPresent(season, forKey: .season)
        try container.encodeIfPresent(seasonYear, forKey: .seasonYear)
        try container.encode(status, forKey: .status)
    }
}

