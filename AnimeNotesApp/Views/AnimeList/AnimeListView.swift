// AnimeListView.swift

import SwiftUI

/// クール別の作品一覧
struct AnimeListView: View {
    @EnvironmentObject private var session: UserSessionViewModel
    @StateObject private var viewModel: AnimeListViewModel

    init(season: AnimeSeason) {
        _viewModel = StateObject(wrappedValue: AnimeListViewModel(season: season))
    }

    var body: some View {
        AnimeCollectionList(
            animes: viewModel.filteredAnimes,
            isLoading: viewModel.isLoading,
            onStatusChange: { anime, status in
                Task { await viewModel.setStatus(status, for: anime) }
            },
            onAnimeUpdate: viewModel.apply
        ) {
            if viewModel.isFiltering {
                EmptyStateView(systemImage: "line.3.horizontal.decrease.circle", title: "条件に一致する作品はありません") {
                    Button("絞り込みを解除") {
                        viewModel.filterText = ""
                        viewModel.statusFilter = nil
                    }
                }
            } else {
                EmptyStateView(
                    systemImage: "tv",
                    title: "\(viewModel.season.displayName)の作品はまだありません",
                    message: "下に引っ張ると再読み込みできます"
                )
            }
        }
        .searchable(text: $viewModel.filterText, prompt: "タイトルで絞り込み")
        .refreshable { await viewModel.reload(userId: session.userId) }
        .navigationTitle("\(viewModel.season.displayName)アニメ")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if session.isAuthenticated {
                    statusFilterMenu
                }
            }
        }
        .task { await viewModel.loadIfNeeded(userId: session.userId) }
        .errorAlert($viewModel.errorMessage)
    }

    private var statusFilterMenu: some View {
        Menu {
            Picker("視聴状況で絞り込み", selection: $viewModel.statusFilter) {
                Text("すべて").tag(WatchStatus?.none)
                ForEach(WatchStatus.menuOrder) { status in
                    Label(status.label, systemImage: status.systemImage).tag(Optional(status))
                }
            }
        } label: {
            Image(systemName: viewModel.statusFilter == nil
                  ? "line.3.horizontal.decrease.circle"
                  : "line.3.horizontal.decrease.circle.fill")
        }
        .accessibilityLabel(Text("視聴状況で絞り込み"))
    }
}
