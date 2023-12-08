// AnimeListViewModel.swift

import Foundation
import Combine
import FirebaseAuth

class AnimeListViewModel: BaseViewModel {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingError: Bool = false
    private var localCancellables = Set<AnyCancellable>()
    let season: String
    
    init(season: String, animeDataService: AnimeDataServiceProtocol = AnimeDataService()) {
        self.season = season
        super.init(animeDataService: animeDataService)
    }
    
    func fetchDataForSeason(isAuthenticated: Bool) {
        isLoading = true
        let components = SeasonUtility.parseSeasonComponents(from: self.season)
        guard components.year > 0, !components.season.isEmpty else {
            self.errorMessage = "Invalid season data."
            self.showingError = true
            isLoading = false
            return
        }

        if isAuthenticated {
            fetchAnimesForAuthenticatedUser(seasonYear: components.year, season: components.season)
        } else {
            fetchAnimesForUnauthenticatedUser(seasonYear: components.year, season: components.season)
        }
    }
    
//    private func parseSeasonAndFetchAnimes(season: String) {
//        let components = SeasonUtility.parseSeasonComponents(from: season)
//        guard components.year > 0, !components.season.isEmpty else {
//            self.errorMessage = "Invalid season data."
//            self.showingError = true
//            return
//        }
//        self.fetchAnimes(seasonYear: components.year, season: components.season)
//    }
    
    private func fetchAnimesForAuthenticatedUser(seasonYear: Int, season: String) {
        isLoading = true
        animeDataService.fetchAnimes(seasonYear: seasonYear, season: season)
            .flatMap { [weak self] animes -> AnyPublisher<[UserAnime], Error> in
                guard let self = self else {
                    return Fail(error: CustomError.unknown).eraseToAnyPublisher()
                }
                return self.fetchAndUpdateUserAnimes(userId: self.userId, animes: animes)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        print("アニメデータのフェッチ中にエラーが発生しました: \(error)")
                        self?.errorMessage = error.localizedDescription
                        self?.showingError = true
                    }
                },
                receiveValue: { [weak self] userAnimes in
                    self?.animes = userAnimes
                }
            )
            .store(in: &localCancellables)
    }
    
    private func fetchAnimesForUnauthenticatedUser(seasonYear: Int, season: String) {
        animeDataService.fetchAnimes(seasonYear: seasonYear, season: season)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    // ... エラーハンドリング
                },
                receiveValue: { [weak self] animes in
                    self?.animes = animes.map { anime in
                        UserAnime(
                            id: "local-\(anime.id ?? "unknown")",
                            user_id: "local",
                            anime_id: Int(anime.id ?? "0") ?? 0,
                            title: anime.title.native,
                            episodes: anime.episodes,
                            season: anime.season,
                            seasonYear: anime.seasonYear,
                            status: 0
                        )
                    }
                }
            )
            .store(in: &localCancellables)
    }
    
    private func fetchAndUpdateUserAnimes(userId: String, animes: [Anime]) -> AnyPublisher<[UserAnime], Error> {
        let userAnimeQueries = animes.map { anime in
            animeDataService.fetchUserAnime(for: anime, userId: userId)
                .flatMap { userAnime -> AnyPublisher<UserAnime, Error> in
                    if userAnime.id.isEmpty {
                        return self.animeDataService.createOrUpdateUserAnime(userId: userId, anime: anime)
                    } else {
                        return Just(userAnime).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }
                }
        }
        return Publishers.MergeMany(userAnimeQueries).collect().eraseToAnyPublisher()
    }
    
    override func updateWatchingStatus(for animeId: Int, newStatus: Int) {
        super.updateWatchingStatus(for: animeId, newStatus: newStatus)
        if let index = animes.firstIndex(where: { $0.anime_id == animeId }) {
            animes[index].status = newStatus
        }
    }
    
    override func selectAnimeForDetail(_ anime: UserAnime) {
        super.selectAnimeForDetail(anime)
    }
}
