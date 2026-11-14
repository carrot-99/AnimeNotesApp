//  StatusAnimeListViewModel.swift

import Foundation

/// 視聴状況別の作品一覧
@MainActor
final class StatusAnimeListViewModel: AnimeCollectionViewModel {
    let status: WatchStatus

    init(status: WatchStatus, animeService: AnimeDataServiceProtocol = AnimeDataService()) {
        self.status = status
        super.init(animeService: animeService)
    }

    func reload(userId: String?) async {
        guard let userId else { return }
        await load {
            try await animeService.fetchHistory(userId: userId, status: status).sortedByTitle()
        }
    }

    /// ステータスが変わった作品は一覧から外す
    override func apply(_ anime: UserAnime) {
        if anime.watchStatus == status {
            super.apply(anime)
        } else {
            animes.removeAll { $0.id == anime.id }
        }
    }
}
