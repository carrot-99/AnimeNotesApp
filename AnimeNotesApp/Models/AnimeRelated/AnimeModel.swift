//  AnimeModel.swift

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// `animes` コレクションのドキュメント（AniList から取り込まれた作品情報）
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

    /// AniList の作品 ID（ドキュメント ID を数値化したもの）
    var animeId: Int? {
        id.flatMap(Int.init)
    }
}
