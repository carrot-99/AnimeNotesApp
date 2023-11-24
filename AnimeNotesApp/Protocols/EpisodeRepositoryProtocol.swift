//  EpisodeDataServiceProtocol.swift

import Combine

protocol EpisodeDataServiceProtocol {
    func fetchEpisodes(for userId: String, animeId: Int) -> AnyPublisher<[UserEpisode], Error>
    func createEpisodesIfNotExist(for userId: String, animeId: Int, episodesCount: Int) -> AnyPublisher<Void, Error>
    func updateEpisodeStatus(userId: String, animeId: Int, episodeNum: Int, newStatus: Int) -> AnyPublisher<Void, Error>
}
