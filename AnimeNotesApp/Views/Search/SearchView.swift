// SearchView.swift

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var session: UserSessionViewModel
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationView {
            AnimeCollectionList(
                animes: viewModel.animes,
                isLoading: viewModel.isLoading,
                onStatusChange: { anime, status in
                    Task { await viewModel.setStatus(status, for: anime) }
                },
                onAnimeUpdate: viewModel.apply
            ) {
                emptyState
            }
            .navigationTitle("検索")
            .searchable(
                text: $viewModel.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "作品タイトル（日本語）"
            )
            .onSubmit(of: .search) {
                Task { await viewModel.search(userId: session.userId) }
            }
            // 入力が止まったら自動で検索する
            .task(id: viewModel.query) {
                try? await Task.sleep(nanoseconds: 500_000_000)
                guard !Task.isCancelled else { return }
                await viewModel.search(userId: session.userId)
            }
            .onChange(of: session.userId) { _ in
                viewModel.reset()
                Task { await viewModel.search(userId: session.userId) }
            }
            .errorAlert($viewModel.errorMessage)
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private var emptyState: some View {
        if let keyword = viewModel.searchedKeyword {
            EmptyStateView(
                systemImage: "magnifyingglass",
                title: "「\(keyword)」に一致する作品は見つかりませんでした",
                message: "タイトルの先頭から入力してください。ひらがな・カタカナ・漢字の違いも区別されます。"
            )
        } else {
            EmptyStateView(
                systemImage: "text.magnifyingglass",
                title: "作品を検索",
                message: "日本語タイトルの先頭一致で検索します。\n例: 「進撃」「ぼっち」"
            )
        }
    }
}
