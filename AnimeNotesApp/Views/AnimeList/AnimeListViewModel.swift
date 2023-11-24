// AnimeListViewModel.swift

import Foundation
import Combine
import FirebaseAuth

class AnimeListViewModel: ObservableObject {
    @Published var animes: [UserAnime] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingError: Bool = false
    @Published var selectedAnime: UserAnime?
    @Published var isAnimeSelected = false
    var userId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    private var cancellables = Set<AnyCancellable>()
    private let animeDataService: AnimeDataServiceProtocol
    let season: String
    
    init(season: String, animeDataService: AnimeDataServiceProtocol = AnimeDataService()) {
        print("AnimeListViewModel初期化中")
        self.season = season
        self.animeDataService = animeDataService
        parseSeasonAndFetchAnimes(season: season)
    }
    
    func parseSeasonAndFetchAnimes(season: String) {
//        print("AnimeListViewModel:parseSeasonAndFetchAnimes")
        let components = SeasonUtility.parseSeasonComponents(from: season)
        guard components.year > 0, !components.season.isEmpty else {
            self.errorMessage = "Invalid season data."
            self.showingError = true
            return
        }
        self.fetchAnimes(seasonYear: components.year, season: components.season)
    }
    
    private func fetchAnimes(seasonYear: Int, season: String) {
//        print("AnimeListViewModel:fetchAnimes")
        print("fetchAnimes called for seasonYear: \(seasonYear), season: \(season)")
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not logged in."
            self.showingError = true
            return
        }
        
        isLoading = true
        animeDataService.fetchAnimes(seasonYear: seasonYear, season: season)
            .flatMap { [weak self] animes -> AnyPublisher<[UserAnime], Error> in
                guard let self = self else {
                    return Fail(error: CustomError.unknown).eraseToAnyPublisher()
                }
                let userAnimeQueries = animes.map { anime in
                    self.animeDataService.fetchUserAnime(for: anime, userId: userId)
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
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        print("Error fetching animes: \(error)")
                        self?.errorMessage = error.localizedDescription
                        self?.showingError = true
                    }
                },
                receiveValue: { [weak self] userAnimes in
                    print("userAnime:\(userAnimes.count)")
                    self?.animes = userAnimes
                }
            )
            .store(in: &cancellables)
    }
    
    private func fetchAndUpdateUserAnimes(userId: String, animes: [Anime]) -> AnyPublisher<[UserAnime], Error> {
//        print("AnimeListViewModel:fetchAndUpdateUserAnimes")
//        print("fetchAndUpdateUserAnimes called for userId: \(userId), animes count: \(animes.count)")
        let userAnimeQueries = animes.map { anime in
            animeDataService.fetchUserAnime(for: anime, userId: userId)
                .flatMap { userAnime -> AnyPublisher<UserAnime, Error> in
                    if userAnime.id.isEmpty {
                        // UserAnimeが存在しない場合、新たに作成
                        return self.animeDataService.createOrUpdateUserAnime(userId: userId, anime: anime)
                    } else {
                        // 既存のUserAnimeを返す
                        return Just(userAnime).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }
                }
        }
        return Publishers.MergeMany(userAnimeQueries).collect().eraseToAnyPublisher()
    }
    
    func selectAnime(_ anime: UserAnime) {
        self.selectedAnime = anime
        self.isAnimeSelected = true
    }
    
    func updateWatchingStatus(animeId: Int, newStatus: Int, userId: String) {
        let animeDataService = AnimeDataService()
        animeDataService.updateWatchingStatus(animeId: animeId, newStatus: newStatus, userId: userId)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error updating status: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] in
                    if let index = self?.animes.firstIndex(where: { $0.anime_id == animeId }) {
                        DispatchQueue.main.async {
                            self?.animes[index].status = newStatus
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }
}
