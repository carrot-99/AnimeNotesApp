// AnimeListView.swift

import SwiftUI
import Combine

struct AnimeListView: View {
    @ObservedObject var viewModel: AnimeListViewModel
    
    var body: some View {
        NavigationStack {
            List(viewModel.animes) { anime in
                AnimeListViewComponent(
                    anime: anime,
                    onStatusIconTap: {
                        viewModel.selectedAnimeForStatusUpdate = anime
                        viewModel.selectedStatus = anime.status
                        viewModel.showingStatusSelection = true
                    },
                    onAnimeTap: {
                        viewModel.selectAnimeForDetail(anime)
                    },
                    updateStatus: { newStatus in
                        // ここでアニメのステータスを更新するロジックを実装します
                        viewModel.updateWatchingStatus(for: anime.anime_id, newStatus: newStatus)
                    }
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .navigationTitle("\(viewModel.season)アニメ")
            .background(Color(UIColor.systemGroupedBackground))
            .sheet(isPresented: $viewModel.showingStatusSelection) {
                if let selectedAnime = viewModel.selectedAnimeForStatusUpdate {
                    StatusSelectionModalView(
                        selectedStatus: $viewModel.selectedStatus,
                        isPresented: $viewModel.showingStatusSelection,
                        updateStatus: { newStatus in
                            viewModel.updateWatchingStatus(for: selectedAnime.anime_id, newStatus: newStatus)
                        }
                    )
                }
            }
        }
        .background(
            NavigationLink(
                destination: viewModel.isAnimeSelected ? AnimeDetailView(
                    anime: viewModel.selectedAnime!,
                    ViewModel: AnimeDetailViewModel(
                        anime: viewModel.selectedAnime!,
                        episodeDataService: EpisodeDataService()
                    )
                ) : nil,
                isActive: $viewModel.isAnimeSelected,
                label: { EmptyView() }
            )
        )
    }
}
