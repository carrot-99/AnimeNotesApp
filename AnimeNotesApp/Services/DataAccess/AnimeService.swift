//  AnimeService.swift

import Combine

class AnimeService {
    static let shared = AnimeService()
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    func updateWatchingStatus(animeId: Int, newStatus: Int, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let animeDataService = AnimeDataService()
        animeDataService.updateWatchingStatus(animeId: animeId, newStatus: newStatus, userId: userId)
            .sink(
                receiveCompletion: { completionResult in
                    switch completionResult {
                    case .failure(let error):
                        completion(.failure(error))
                    case .finished:
                        break
                    }
                },
                receiveValue: {
                    completion(.success(()))
                }
            )
            .store(in: &cancellables)
    }
}
