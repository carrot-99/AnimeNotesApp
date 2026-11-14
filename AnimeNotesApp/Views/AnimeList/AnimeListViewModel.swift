// AnimeListViewModel.swift

import Foundation

/// クール別の作品一覧
@MainActor
final class AnimeListViewModel: AnimeCollectionViewModel {
    let season: AnimeSeason

    @Published var filterText = ""
    @Published var statusFilter: WatchStatus?

    private var hasLoaded = false

    init(season: AnimeSeason, animeService: AnimeDataServiceProtocol = AnimeDataService()) {
        self.season = season
        super.init(animeService: animeService)
    }

    /// 絞り込み後の一覧
    var filteredAnimes: [UserAnime] {
        let keyword = filterText.trimmingCharacters(in: .whitespacesAndNewlines)
        return animes.filter { anime in
            (statusFilter == nil || anime.watchStatus == statusFilter)
                && (keyword.isEmpty || anime.title.localizedCaseInsensitiveContains(keyword))
        }
    }

    var isFiltering: Bool {
        statusFilter != nil || !filterText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func loadIfNeeded(userId: String?) async {
        guard !hasLoaded else { return }
        await reload(userId: userId)
    }

    func reload(userId: String?) async {
        await load {
            let animes = try await animeService.fetchAnimes(in: season)
            return try await animeService.userAnimes(for: animes, userId: userId).sortedByTitle()
        }
        hasLoaded = errorMessage == nil
    }
}
