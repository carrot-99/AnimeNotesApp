// AnimeDataServiceProtocol.swift

import Foundation

protocol AnimeDataServiceProtocol {
    /// 指定クールの作品一覧
    func fetchAnimes(in season: AnimeSeason) async throws -> [Anime]
    /// タイトルの前方一致検索
    func searchAnimes(title: String) async throws -> [Anime]
    /// 指定した作品に対するユーザーの視聴履歴
    func fetchHistory(userId: String, animeIds: [Int]) async throws -> [UserAnime]
    /// 指定ステータスの視聴履歴
    func fetchHistory(userId: String, status: WatchStatus) async throws -> [UserAnime]
    /// ステータスごとの作品数
    func fetchStatusCounts(userId: String) async throws -> [WatchStatus: Int]
    /// 視聴状況を保存する（ドキュメントがなければ作成する）
    func save(_ anime: UserAnime) async throws
}

extension AnimeDataServiceProtocol {
    /// 作品一覧にユーザーの視聴状況を反映する。`userId` が nil（ゲスト）の場合は全て未視聴。
    func userAnimes(for animes: [Anime], userId: String?) async throws -> [UserAnime] {
        guard let userId else {
            return UserAnime.merge(animes: animes, history: [], userId: UserAnime.guestUserId)
        }
        let history = try await fetchHistory(userId: userId, animeIds: animes.compactMap(\.animeId))
        return UserAnime.merge(animes: animes, history: history, userId: userId)
    }
}
