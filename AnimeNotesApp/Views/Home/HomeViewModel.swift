//  HomeViewModel.swift

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var counts: [WatchStatus: Int] = [:]
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let animeService: AnimeDataServiceProtocol

    init(animeService: AnimeDataServiceProtocol = AnimeDataService()) {
        self.animeService = animeService
    }

    func count(for status: WatchStatus) -> Int? {
        counts[status]
    }

    var totalCount: Int {
        counts.values.reduce(0, +)
    }

    func reload(userId: String?) async {
        guard let userId else {
            counts = [:]
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            counts = try await animeService.fetchStatusCounts(userId: userId)
        } catch is CancellationError {
        } catch {
            errorMessage = error.userMessage
        }
    }
}
