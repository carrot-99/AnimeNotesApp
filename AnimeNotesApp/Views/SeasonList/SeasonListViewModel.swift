//  SeasonListViewModel.swift

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class SeasonListViewModel: ObservableObject {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @Published var seasons: [String] = []
    @Published var hasError = false
    @Published var selectedSeason: String?
    @Published var navigateToAnimeList = false
    @Published var error: IdentifiableError? {
        didSet {
            hasError = error != nil
        }
    }
    private var cancellables = Set<AnyCancellable>()
    private var animeListViewModels: [String: AnimeListViewModel] = [:]
    
    init() {
        generateSeasonsList()
    }
    
    func viewModelForSeason(_ season: String) -> AnimeListViewModel {
        if let viewModel = animeListViewModels[season] {
            return viewModel
        } else {
            let newViewModel = AnimeListViewModel(season: season)
            animeListViewModels[season] = newViewModel
            return newViewModel
        }
    }
    
    private func generateSeasonsList() {
        let seasonsOrder = ["冬", "春", "夏", "秋"]

        for year in (1940...2023).reversed() {
            for season in seasonsOrder.reversed() {
                let seasonString = "\(year)\(season)"
                seasons.append(seasonString)
            }
        }
    }
    
    func handleError(_ error: IdentifiableError) {
        self.error = error
    }
    
    var errorMessage: String {
        self.error?.message ?? "不明なエラーが発生しました"
    }
    
    func dismissError() {
        self.error = nil
    }
}

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
