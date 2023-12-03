//  EpisodeDataService.swift

import Combine

class EpisodeDataService: FirestoreService, EpisodeDataServiceProtocol {
    func fetchEpisodes(for userId: String, animeId: Int) -> AnyPublisher<[UserEpisode], Error> {
        let episodesRef = db.collection("userWatchingHistory")
            .document("\(userId)-\(animeId)")
            .collection("episodesHistory")
        return performQuery(episodesRef, decodingType: UserEpisode.self)
    }
    
    func createEpisodesIfNotExist(for userId: String, animeId: Int, episodesCount: Int) -> AnyPublisher<Void, Error> {
        guard episodesCount > 0 else {
            return Fail(error: CustomError.invalidEpisodeCount).eraseToAnyPublisher()
        }

        var publishers = [AnyPublisher<Void, Error>]()
        for episodeNum in 1...episodesCount {
            let episodeId = "\(userId)-\(animeId)-\(episodeNum)"
            let newEpisode = UserEpisode(id: episodeId, user_id: userId, anime_id: animeId, episode_num: episodeNum, status: 0)
            let documentRef = db.collection("userWatchingHistory")
                                .document("\(userId)-\(animeId)")
                                .collection("episodesHistory")
                                .document(episodeId)
            publishers.append(setData(documentRef, for: newEpisode))
        }
        return Publishers.MergeMany(publishers).collect().map { _ in () }.eraseToAnyPublisher()
    }

    func updateEpisodeStatus(userId: String, animeId: Int, episodeNum: Int, newStatus: Int) -> AnyPublisher<Void, Error> {
        let documentId = "\(userId)-\(animeId)-\(episodeNum)"
        let episodeRef = db.collection("userWatchingHistory")
                            .document("\(userId)-\(animeId)")
                            .collection("episodesHistory")
                            .document(documentId)
        return updateData(episodeRef, data: ["status": newStatus])
    }
}
