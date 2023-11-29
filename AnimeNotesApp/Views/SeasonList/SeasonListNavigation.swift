//  SeasonListNavigation.swift

import SwiftUI

extension SeasonListViewModel {
    func selectSeason(_ season: String) {
        self.selectedSeason = season
        self.navigateToAnimeList = true
    }

    func navigateToAnimeDetail() -> AnimeListView? {
        guard let season = selectedSeason else { return nil }
        let viewModel = viewModelForSeason(season)
        return AnimeListView(viewModel: viewModel)
    }

    func resetNavigationState() {
        self.navigateToAnimeList = false
        self.selectedSeason = nil
    }
}
