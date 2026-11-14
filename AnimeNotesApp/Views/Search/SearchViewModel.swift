// SearchViewModel.swift

import Foundation

@MainActor
final class SearchViewModel: AnimeCollectionViewModel {
    @Published var query = ""
    /// 最後に検索したキーワード（未検索なら nil）
    @Published private(set) var searchedKeyword: String?

    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func search(userId: String?) async {
        let keyword = trimmedQuery
        guard !keyword.isEmpty else {
            animes = []
            searchedKeyword = nil
            return
        }
        guard keyword != searchedKeyword else { return }

        await load {
            let animes = try await animeService.searchAnimes(title: keyword)
            return try await animeService.userAnimes(for: animes, userId: userId).sortedByTitle()
        }
        // 入力が進んでいる場合、古い結果は使わない
        if keyword == trimmedQuery {
            searchedKeyword = keyword
        }
    }

    /// ログイン状態が変わった場合などに再検索させる
    func reset() {
        searchedKeyword = nil
    }
}
