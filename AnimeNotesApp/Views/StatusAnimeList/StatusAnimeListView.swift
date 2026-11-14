//  StatusAnimeListView.swift

import SwiftUI

/// 視聴状況別の作品一覧
struct StatusAnimeListView: View {
    @EnvironmentObject private var session: UserSessionViewModel
    @StateObject private var viewModel: StatusAnimeListViewModel

    init(status: WatchStatus) {
        _viewModel = StateObject(wrappedValue: StatusAnimeListViewModel(status: status))
    }

    var body: some View {
        AnimeCollectionList(
            animes: viewModel.animes,
            isLoading: viewModel.isLoading,
            onStatusChange: { anime, status in
                Task { await viewModel.setStatus(status, for: anime) }
            },
            onAnimeUpdate: viewModel.apply
        ) {
            EmptyStateView(
                systemImage: viewModel.status.systemImage,
                title: "\(viewModel.status.listTitle)はありません",
                message: "クール一覧や検索から作品の視聴状況を設定すると、ここに表示されます。"
            )
        }
        .refreshable { await viewModel.reload(userId: session.userId) }
        .navigationTitle(viewModel.status.listTitle)
        .task { await viewModel.reload(userId: session.userId) }
        .errorAlert($viewModel.errorMessage)
    }
}
