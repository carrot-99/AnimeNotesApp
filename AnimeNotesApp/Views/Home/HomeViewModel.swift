//  HomeViewModel.swift

import Foundation
import Combine
import FirebaseAuth

class HomeViewModel: ObservableObject {
    @Published var watchedAnimeCount = 0
    @Published var watchingAnimeCount = 0
    @Published var onHoldAnimeCount = 0
    @Published var plannedAnimeCount = 0
    
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
                    self?.plannedAnimeCount = statusCounts.planned
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
        case .planned:
            return plannedAnimeCount
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
    var planned: Int
}

enum UserAnimeStatus: Int, CaseIterable {
    case watched = 3
    case watching = 1
    case onHold = 2
    case planned = 4
    
    var description: String {
        switch self {
        case .watched:
            return "視聴済作品"
        case .watching:
            return "視聴中作品"
        case .onHold:
            return "視聴中断作品"
        case .planned:
            return "視聴予定作品"
        }
    }
}
