//  AnimeDetailViewModel.swift

import Foundation
import FirebaseFirestore
import Combine

class AnimeDetailViewModel: ObservableObject {
    @Published var episodes: [UserEpisode] = []
    @Published var isLoading = false
    @Published var showingStatusSelection = false
    @Published var selectedStatus: Int = 0
    private var selectedEpisode: UserEpisode?
    private var cancellables = Set<AnyCancellable>()
    private let episodeDataService: EpisodeDataServiceProtocol

    
    init(anime: UserAnime, episodeDataService: EpisodeDataServiceProtocol) {
        self.episodeDataService = episodeDataService
        fetchEpisodes(for: anime)
    }

    func fetchEpisodes(for anime: UserAnime) {
        isLoading = true
        
        episodeDataService.fetchEpisodes(for: anime.user_id, animeId: anime.anime_id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        print("Error fetching episodes: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] episodes in
                    if !episodes.isEmpty {
                        self?.episodes = episodes.sorted(by: { $0.episode_num < $1.episode_num })
                    } else {
                        self?.createEpisodesIfNotExist(for: anime)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func createEpisodesIfNotExist(for anime: UserAnime) {
        guard let episodesCount = anime.episodes, episodesCount > 0 else {
            return
        }
        
        episodeDataService.createEpisodesIfNotExist(for: anime.user_id, animeId: anime.anime_id, episodesCount: episodesCount)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(_) = completion {
                        print("Error in creating episodes")
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.fetchEpisodes(for: anime)
                }
            )
            .store(in: &cancellables)
    }
    
    func selectEpisode(_ episode: UserEpisode) {
        self.selectedEpisode = episode
        self.showingStatusSelection = true
        self.selectedStatus = episode.status
    }
    
    func updateStatusForSelectedEpisode() {
        guard let selectedEpisode = selectedEpisode else { return }
        episodeDataService.updateEpisodeStatus(userId: selectedEpisode.user_id, animeId: selectedEpisode.anime_id, episodeNum: selectedEpisode.episode_num, newStatus: selectedStatus)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(_) = completion {
                        print("Error updating episode status")
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.selectedStatus = self?.selectedEpisode?.status ?? 0
                    if let index = self?.episodes.firstIndex(where: { $0.episode_num == selectedEpisode.episode_num }) {
                        self?.episodes[index].status = self?.selectedStatus ?? 0
                    }
                    self?.showingStatusSelection = false
                }
            )
            .store(in: &cancellables)
    }
    
    func seasonTranslate(season: String) -> String {
        var translatedSeason: String
        
        switch season {
        case "SPRING":
            translatedSeason = "春"
        case "SUMMER":
            translatedSeason = "夏"
        case "FALL":
            translatedSeason = "秋"
        case "WINTER":
            translatedSeason = "冬"
        default:
            translatedSeason = season
        }
        
        return translatedSeason
    }
}

