//  StatusAnimeListViewModel.swift

import Foundation
import Combine
import FirebaseAuth

class StatusAnimeListViewModel: BaseViewModel {
    let status: Int
    private var localCancellables = Set<AnyCancellable>()

    init(
        status: Int,
        animeDataService: AnimeDataServiceProtocol = AnimeDataService(),
        authenticationService: AuthenticationServiceProtocol = AuthenticationService()
    ) {
        self.status = status
        super.init(animeDataService: animeDataService)
        fetchStatusAnimes(for: self.userId, with: status)
    }

    func fetchStatusAnimes(for userId: String, with status: Int) {
        localCancellables.forEach { $0.cancel() }
        localCancellables.removeAll()
        
        animeDataService.fetchStatusAnimes(userId: userId, status: status)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] animes in
                    self?.animes = animes
                }
            )
            .store(in: &localCancellables)
    }
    
    override func updateWatchingStatus(for animeId: Int, newStatus: Int) {
        super.updateWatchingStatus(for: animeId, newStatus: newStatus)
        fetchStatusAnimes(for: userId, with: status)
    }
    
    override func selectAnimeForDetail(_ anime: UserAnime) {
        super.selectAnimeForDetail(anime)
    }
}
