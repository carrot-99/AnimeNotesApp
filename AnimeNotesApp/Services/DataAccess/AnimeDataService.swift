//  AnimeDataService.swift

import Combine

class AnimeDataService: FirestoreService, AnimeDataServiceProtocol {
    func fetchAnimes(seasonYear: Int, season: String) -> AnyPublisher<[Anime], Error> {
        print("AnimeDataService:fetchAnimes")
        let query = db.collection("animes")
            .whereField("seasonYear", isEqualTo: seasonYear)
            .whereField("season", isEqualTo: season)
        return performQuery(query, decodingType: Anime.self)
    }
    
    func createOrUpdateUserAnime(userId: String, anime: Anime) -> AnyPublisher<UserAnime, Error> {
        print("AnimeDataService:createOrUpdateUserAnime \(anime.title.native)")
        let userAnime = UserAnime(
            id: "\(userId)-\(anime.id ?? "")",
            user_id: userId,
            anime_id: Int(anime.id ?? "0")!,
            title: anime.title.native,
            episodes: anime.episodes,
            season: anime.season,
            seasonYear: anime.seasonYear,
            status: 0 // 初期ステータス
        )
        let documentRef = db.collection("userWatchingHistory").document(userAnime.id)
        return setData(documentRef, for: userAnime)
            .map { _ in userAnime }
            .eraseToAnyPublisher()
    }
    
    func fetchStatusAnimes(userId: String, status: Int) -> AnyPublisher<[UserAnime], Error> {
        let query = db.collection("userWatchingHistory")
            .whereField("user_id", isEqualTo: userId)
            .whereField("status", isEqualTo: status)
        return performQuery(query, decodingType: UserAnime.self)
    }
    
    func updateWatchingStatus(animeId: Int, newStatus: Int, userId: String) -> AnyPublisher<Void, Error> {
        let documentId = "\(userId)-\(animeId)"
        let documentRef = db.collection("userWatchingHistory").document(documentId)
        return updateData(documentRef, data: ["status": newStatus])
    }
    
    func searchAnimesByTitle(userId: String, title: String) -> AnyPublisher<[UserAnime], Error> {
        let query = db.collection("animes")
            .whereField("title.native", isGreaterThanOrEqualTo: title)
            .whereField("title.native", isLessThanOrEqualTo: title + "\u{f8ff}")
        
        return performQuery(query, decodingType: Anime.self).flatMap { [weak self] animes -> AnyPublisher<[UserAnime], Error> in
            guard let self = self else {
                return Fail(error: CustomError.unknown).eraseToAnyPublisher()
            }
            
            let userAnimeQueries = animes.map { anime -> AnyPublisher<UserAnime, Error> in
                self.fetchUserAnime(for: anime, userId: userId)
            }
            
            return Publishers.MergeMany(userAnimeQueries).collect().eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    func fetchUserAnime(for anime: Anime, userId: String) -> AnyPublisher<UserAnime, Error> {
        let userAnimeRef = self.db.collection("userWatchingHistory")
            .whereField("anime_id", isEqualTo: Int(anime.id ?? "0") ?? 0)
            .whereField("user_id", isEqualTo: userId)
        return performQuery(userAnimeRef, decodingType: UserAnime.self)
            .flatMap { userAnimes -> AnyPublisher<UserAnime, Error> in
                if let foundUserAnime = userAnimes.first {
                    return Just(foundUserAnime)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    let newUserAnime = UserAnime(
                        id: "\(userId)-\(anime.id ?? "")",
                        user_id: userId,
                        anime_id: Int(anime.id ?? "0")!,
                        title: anime.title.native,
                        episodes: anime.episodes,
                        season: anime.season,
                        seasonYear: anime.seasonYear,
                        status: 0
                    )
                    let documentRef = self.db.collection("userWatchingHistory").document(newUserAnime.id)
                    return self.setData(documentRef, for: newUserAnime)
                        .map { _ in newUserAnime }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchStatusCounts(userId: String) -> AnyPublisher<StatusCounts, Error> {

        func countForStatus(_ status: Int) -> AnyPublisher<Int, Error> {
            let query = db.collection("userWatchingHistory")
                .whereField("user_id", isEqualTo: userId)
                .whereField("status", isEqualTo: status)
            return performQuery(query, decodingType: UserAnime.self)
                .map { $0.count }
                .eraseToAnyPublisher()
        }

        return Publishers.CombineLatest4(
            countForStatus(UserAnimeStatus.watched.rawValue),
            countForStatus(UserAnimeStatus.watching.rawValue),
            countForStatus(UserAnimeStatus.onHold.rawValue),
            countForStatus(UserAnimeStatus.planned.rawValue)
        )
        .map { watchedCount, watchingCount, onHoldCount, plannedCount in
            StatusCounts(watched: watchedCount, watching: watchingCount, onHold: onHoldCount, planned: plannedCount)
        }
        .eraseToAnyPublisher()
    }
}


