// AnimeListViewModel.swift

import Foundation
import Combine
import FirebaseAuth

class AnimeListViewModel: BaseViewModel {
    @Published var isLoading: Bool = false {
        didSet {
            print("isLoading changed to: \(isLoading)")
        }
    }
    @Published var errorMessage: String?
    @Published var showingError: Bool = false
    private var localCancellables = Set<AnyCancellable>()
    let season: String
    
    init(
        season: String,
        animeDataService: AnimeDataServiceProtocol = AnimeDataService()
    ) {
        self.season = season
        super.init(animeDataService: animeDataService)
        parseSeasonAndFetchAnimes(season: season)
    }
    
    private func parseSeasonAndFetchAnimes(season: String) {
        let components = SeasonUtility.parseSeasonComponents(from: season)
        guard components.year > 0, !components.season.isEmpty else {
            self.errorMessage = "Invalid season data."
            self.showingError = true
            return
        }
        self.fetchAnimes(seasonYear: components.year, season: components.season)
    }
    
    private func fetchAnimes(seasonYear: Int, season: String) {
        print("fetchAnimes started for season: \(seasonYear) \(season)")
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
                    print("fetchAnimes completed for season: \(seasonYear) \(season)")
                    if case let .failure(error) = completion {
                        print("Error fetching animes: \(error)")
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
        print("AnimeListViewModel selectAnimeForDetail \(anime.title)")
        super.selectAnimeForDetail(anime)
    }
}
