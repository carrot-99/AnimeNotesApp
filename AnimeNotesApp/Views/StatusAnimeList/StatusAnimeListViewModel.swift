//  StatusAnimeListViewModel.swift

import Foundation
import Combine
import FirebaseAuth

class StatusAnimeListViewModel: ObservableObject {
    @Published var animes: [UserAnime] = []
    @Published var isAnimeSelected = false
    @Published var selectedAnime: UserAnime?
    @Published var showingStatusSelection = false
    @Published var selectedAnimeForStatusUpdate: UserAnime?
    @Published var selectedStatus: Int = 0
    private var cancellables: Set<AnyCancellable> = []
    private let animeDataService: AnimeDataServiceProtocol
    private var authenticationService: AuthenticationServiceProtocol
    var userId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    let status: Int

    init(
        status: Int,
        animeDataService: AnimeDataServiceProtocol = AnimeDataService(),
        authenticationService: AuthenticationServiceProtocol = AuthenticationService()
    ) {
        self.status = status
        self.animeDataService = animeDataService
        self.authenticationService = authenticationService
    }

    func fetchStatusAnimes(for userId: String, with status: Int) {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
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
            .store(in: &cancellables)
    }
    
    func updateWatchingStatus(for animeId: Int, newStatus: Int) {
        let userId = authenticationService.currentUserId
        animeDataService.updateWatchingStatus(animeId: animeId, newStatus: newStatus, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error updating status: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.fetchStatusAnimes(for: userId, with: self?.status ?? 0)
                }
            )
            .store(in: &cancellables)
    }
    
    func selectAnimeForStatusUpdate(_ anime: UserAnime) {
        selectedAnimeForStatusUpdate = anime
        showingStatusSelection = true
    }
}
