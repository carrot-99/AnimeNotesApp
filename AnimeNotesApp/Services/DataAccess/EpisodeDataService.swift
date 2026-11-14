//  EpisodeDataService.swift

import FirebaseFirestore

final class EpisodeDataService: FirestoreService, EpisodeDataServiceProtocol {
    private func episodesCollection(userId: String, animeId: Int) -> CollectionReference {
        db.collection(FirestoreCollection.watchingHistory)
            .document(UserAnime.documentId(userId: userId, animeId: animeId))
            .collection(FirestoreCollection.episodesHistory)
    }

    func fetchEpisodes(userId: String, animeId: Int) async throws -> [UserEpisode] {
        try await documents(episodesCollection(userId: userId, animeId: animeId), as: UserEpisode.self)
    }

    func save(_ episodes: [UserEpisode]) async throws {
        try await commitInBatches(episodes) { batch, episode in
            let reference = episodesCollection(userId: episode.user_id, animeId: episode.anime_id).document(episode.id)
            try batch.setData(from: episode, forDocument: reference, merge: true)
        }
    }
}
