//  EpisodeDataServiceProtocol.swift

import Foundation

protocol EpisodeDataServiceProtocol {
    /// 保存済みのエピソード視聴履歴（記録のないエピソードは含まれない）
    func fetchEpisodes(userId: String, animeId: Int) async throws -> [UserEpisode]
    /// エピソードの視聴状況を保存する（ドキュメントがなければ作成する）
    func save(_ episodes: [UserEpisode]) async throws
}
