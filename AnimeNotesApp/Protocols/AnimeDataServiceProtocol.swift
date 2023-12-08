// AnimeDataServiceProtocol.swift

import Combine

protocol AnimeDataServiceProtocol {
    func fetchAnimes(seasonYear: Int, season: String) -> AnyPublisher<[Anime], Error>
    func createOrUpdateUserAnime(userId: String, anime: Anime) -> AnyPublisher<UserAnime, Error>
    func fetchStatusAnimes(userId: String, status: Int) -> AnyPublisher<[UserAnime], Error>
    func fetchUserAnime(for anime: Anime, userId: String) -> AnyPublisher<UserAnime, Error>
    func updateWatchingStatus(animeId: Int, newStatus: Int, userId: String) -> AnyPublisher<Void, Error>
    func searchAnimesByTitleForAuthenticatedUser(userId: String, title: String) -> AnyPublisher<[UserAnime], Error>
    func searchAnimesByTitleForUnauthenticatedUser(title: String) -> AnyPublisher<[Anime], Error>
}
