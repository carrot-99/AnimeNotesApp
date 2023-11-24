//  HomeViewModel.swift

import Foundation
import Combine
import FirebaseAuth

class HomeViewModel: ObservableObject {
    @Published var watchedAnimeCount = 0
    @Published var watchingAnimeCount = 0
    @Published var onHoldAnimeCount = 0
    
    private var authService: AuthenticationService
    private var cancellables = Set<AnyCancellable>()
    private var statusViewModels: [Int: StatusAnimeListViewModel] = [:]
    
    init(authService: AuthenticationService) {
        self.authService = authService
        refreshStatusCounts()
    }
    
    var userId: String {
        return authService.currentUserId
    }

    func refreshStatusCounts() {
        fetchStatusCounts(userId: userId)
    }
    
    private func fetchStatusCounts(userId: String) {
        AnimeDataService().fetchStatusCounts(userId: userId)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] statusCounts in
                    self?.watchedAnimeCount = statusCounts.watched
                    self?.watchingAnimeCount = statusCounts.watching
                    self?.onHoldAnimeCount = statusCounts.onHold
                }
            )
            .store(in: &cancellables)
    }
    
    func count(for status: UserAnimeStatus) -> Int {
        switch status {
        case .watched:
            return watchedAnimeCount
        case .watching:
            return watchingAnimeCount
        case .onHold:
            return onHoldAnimeCount
        }
    }
    
    func getOrCreateStatusViewModel(for status: Int) -> StatusAnimeListViewModel {
        if let viewModel = statusViewModels[status] {
            return viewModel
        } else {
            let newViewModel = StatusAnimeListViewModel(status: status, animeDataService: AnimeDataService(), authenticationService: AuthenticationService())
            statusViewModels[status] = newViewModel
            return newViewModel
        }
    }
}

struct StatusCounts {
    var watched: Int
    var watching: Int
    var onHold: Int
}

enum UserAnimeStatus: Int, CaseIterable {
    case watched = 3
    case watching = 1
    case onHold = 2
    
    var description: String {
        switch self {
        case .watched:
            return "視聴済作品"
        case .watching:
            return "視聴中作品"
        case .onHold:
            return "視聴中断作品"
        }
    }
}
