//  StatusAnimeListView.swift

import SwiftUI
import Combine

struct StatusAnimeListView: View {
    @ObservedObject var viewModel: StatusAnimeListViewModel
    @State private var selectedAnime: UserAnime?
    @State private var isShowingDetailView = false
    @State private var isShowingStatusSelection = false
    @State private var selectedStatus: Int = 0
    @State private var selectedAnimeId: Int = 0

    var body: some View {
        List(viewModel.animes) { anime in
            HStack {
                Image(systemName: iconForStatus(anime.status))
                    .onTapGesture {
                        viewModel.selectAnimeForStatusUpdate(anime)
//                        self.selectedAnimeId = anime.anime_id
                        self.selectedStatus = anime.status
//                        self.isShowingStatusSelection = true
//                        print("Status icon tapped for anime ID: \(anime.anime_id)")
                    }
                Button(action: {
                    self.selectedAnime = anime
                    self.isShowingDetailView = true
                }) {
                    Text(anime.title)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingStatusSelection) {
            if let selectedAnime = viewModel.selectedAnimeForStatusUpdate {
                StatusSelectionModalView(
                    selectedStatus: self.$selectedStatus,
                    isPresented: $viewModel.showingStatusSelection,
                    updateStatus: { newStatus in
                        viewModel.updateWatchingStatus(for: selectedAnime.anime_id, newStatus: newStatus)
                    }
                )
            } else {
                Text("情報を読み込めませんでした。")
            }
        }
        .background(
            Group {
                if isShowingDetailView, let selectedAnime = selectedAnime {
                    NavigationLink(
                        destination: AnimeDetailView(anime: selectedAnime, detailViewModel: AnimeDetailViewModel(anime: selectedAnime, episodeDataService: EpisodeDataService())),
                        isActive: $isShowingDetailView
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
