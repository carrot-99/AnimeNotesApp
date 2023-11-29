//  BaseViewModel.swift

import Foundation
import Combine
import FirebaseAuth

class BaseViewModel: ObservableObject {
    @Published var animes: [UserAnime] = []
    @Published var selectedAnime: UserAnime?
    @Published var isAnimeSelected: Bool = false
    @Published var selectedAnimeForStatusUpdate: UserAnime?
    @Published var selectedStatus: Int = 0
    @Published var showingStatusSelection: Bool = false
    var userId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    private var cancellables = Set<AnyCancellable>()
    let animeDataService: AnimeDataServiceProtocol

    init(animeDataService: AnimeDataServiceProtocol = AnimeDataService()) {
        self.animeDataService = animeDataService
    }

    func selectAnimeForDetail(_ anime: UserAnime) {
        selectedAnime = anime
        isAnimeSelected = true
    }

    func selectAnimeForStatusUpdate(_ anime: UserAnime) {
        selectedAnimeForStatusUpdate = anime
        selectedStatus = anime.status
        showingStatusSelection = true
    }

    func updateWatchingStatus(for animeId: Int, newStatus: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        animeDataService.updateWatchingStatus(animeId: animeId, newStatus: newStatus, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print("Error updating status: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] in
                    self?.handleStatusUpdate(animeId: animeId, newStatus: newStatus)
                }
            )
            .store(in: &cancellables)
    }

    func handleStatusUpdate(animeId: Int, newStatus: Int) {
        // サブクラスでオーバーライドするためのメソッド
    }
}
