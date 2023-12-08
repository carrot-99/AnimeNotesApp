// SearchViewModel.swift

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchResults: [UserAnime] = []
    @Published var searchResultsForUnauthenticatedUser: [Anime] = []
    @Published var isLoading = false
    @Published var hasSearched = false
    @Published var selectedAnime: UserAnime?
    @Published var isAnimeSelected = false
    @Published var selectedAnimeForStatusUpdate: UserAnime?
    @Published var selectedStatus: Int = 0
    @Published var showingStatusSelection = false
    private var animeDataService: AnimeDataServiceProtocol
    private var authenticationService: AuthenticationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(animeDataService: AnimeDataServiceProtocol = AnimeDataService(),
         authenticationService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.animeDataService = animeDataService
        self.authenticationService = authenticationService
    }
    
    func searchAnimeByTitleForAuthenticatedUser(title: String) {
        isLoading = true
        hasSearched = true
        searchResults.removeAll()
        
        let userId = authenticationService.currentUserId
        guard !userId.isEmpty else { return }

        animeDataService.searchAnimesByTitleForAuthenticatedUser(userId: userId, title: title)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    print("Error searching anime: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] userAnimes in
                guard let self = self else { return }
                self.searchResults = userAnimes.sorted(by: { $0.title < $1.title })
            })
            .store(in: &cancellables)
    }
    
    func searchAnimeByTitleForUnauthenticatedUser(title: String) {
        isLoading = true
        hasSearched = true
        searchResults.removeAll()
        
        animeDataService.searchAnimesByTitleForUnauthenticatedUser(title: title)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    print("Error searching anime: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] animes in
                guard let self = self else { return }
                self.searchResultsForUnauthenticatedUser = animes.map { anime in
                    Anime(
                        id: anime.id,
                        title: anime.title,
                        seasonYear: anime.seasonYear,
                        season: anime.season,
                        episodes: anime.episodes
                    )
                }
            })
            .store(in: &cancellables)
    }
    
    func updateWatchingStatus(for animeId: Int, newStatus: Int) {
        let userId = authenticationService.currentUserId
        guard !userId.isEmpty else { return }

        animeDataService.updateWatchingStatus(animeId: animeId, newStatus: newStatus, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error updating status: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] in
                guard let self = self else { return }
                if let index = searchResults.firstIndex(where: { $0.anime_id == animeId }) {
                    self.searchResults[index].status = newStatus
                    // selectedAnimeの状態も更新
                    if let selectedAnime = self.selectedAnime, selectedAnime.anime_id == animeId {
                        var updatedAnime = selectedAnime
                        updatedAnime.status = newStatus
                        self.selectedAnime = updatedAnime
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    func selectAnime(_ anime: UserAnime) {
        self.selectedAnime = anime
        self.isAnimeSelected = true
    }
    
    func selectAnimeForStatusUpdate(_ anime: UserAnime) {
        selectedAnimeForStatusUpdate = anime
        selectedStatus = anime.status
        showingStatusSelection = true
    }

    func selectAnimeForDetail(_ anime: UserAnime) {
        selectedAnime = anime
        isAnimeSelected = true
    }
}
