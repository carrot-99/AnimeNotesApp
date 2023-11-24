//  AnimeModel.swift

import Foundation
import FirebaseFirestore

// MARK: - animes構造体
struct Anime: Codable, Identifiable {
    @DocumentID var id: String?
    var title: Title
    var seasonYear: Int?
    var season: String?
    var episodes: Int?
    var status: String?

    struct Title: Codable {
        var native: String
    }
}

extension Anime {
    var seasonLocalized: String {
        guard let season = self.season?.uppercased() else { return "--" }
        let seasonKey: String
        switch season {
        case "SPRING":
            seasonKey = "season_spring"
        case "SUMMER":
            seasonKey = "season_summer"
        case "FALL":
            seasonKey = "season_fall"
        case "WINTER":
            seasonKey = "season_winter"
        default:
            return "--"
        }
        return NSLocalizedString(seasonKey, comment: "")
    }
}
