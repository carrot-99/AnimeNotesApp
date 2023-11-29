//  StatusAnimeListView.swift

import SwiftUI
import Combine

struct StatusAnimeListView: View {
    @ObservedObject var viewModel: StatusAnimeListViewModel

    var body: some View {
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
                }
            )
        }
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
        .background(
            Group {
                if viewModel.isAnimeSelected, let anime = viewModel.selectedAnime {
                    NavigationLink(
                        destination: AnimeDetailView(anime: anime, ViewModel: AnimeDetailViewModel(anime: anime, episodeDataService: EpisodeDataService())),
                        isActive: $viewModel.isAnimeSelected
                    ) {
                        EmptyView()
                    }
                }
            }
        )
        .navigationTitle(titleForStatus(viewModel.status))
        .onAppear {
            viewModel.fetchStatusAnimes(for: viewModel.userId, with: viewModel.status)
        }
    }
    
    func titleForStatus(_ status: Int) -> String {
        switch status {
        case 1:
            return "視聴中作品"
        case 2:
            return "視聴中断作品"
        case 3:
            return "視聴済作品"
        default:
            return "未視聴作品"
        }
    }
}
