//  AnimeDetailView.swift

import SwiftUI
import FirebaseAuth

struct AnimeDetailView: View {
    var anime: UserAnime
    @ObservedObject var detailViewModel: AnimeDetailViewModel
    
    var showingStatusSelectionBinding: Binding<Bool> {
        Binding(
            get: { self.detailViewModel.showingStatusSelection },
            set: { self.detailViewModel.showingStatusSelection = $0 }
        )
    }

    var selectedStatusBinding: Binding<Int> {
        Binding(
            get: { self.detailViewModel.selectedStatus },
            set: { self.detailViewModel.selectedStatus = $0 }
        )
    }
    
    init(anime: UserAnime, detailViewModel: AnimeDetailViewModel) {
        self.anime = anime
        self.detailViewModel = detailViewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(anime.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    Text("放送時期：")
                        .fontWeight(.semibold)
                    Text(anime.seasonYear != nil ? "\(anime.seasonYear!)" : "--")
                    Text(anime.season ?? "-")
                }

                Text(anime.episodes != nil ? "全\(anime.episodes!)話" : "全--話")
                
                if detailViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                } else {
                    ForEach(detailViewModel.episodes, id: \.id) { episode in
                        HStack {
                            Image(systemName: iconForStatus(episode.status))
                                .onTapGesture {
                                    detailViewModel.selectEpisode(episode)
                                }
                            Text("エピソード \(episode.episode_num)")
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle(Text(anime.title), displayMode: .inline)
        .onAppear {
            print("AnimeDetailViewが表示されました:\(anime.title)")
            detailViewModel.fetchEpisodes(for: anime)
        }
        .sheet(isPresented: $detailViewModel.showingStatusSelection) {
            StatusSelectionModalView(
                selectedStatus: $detailViewModel.selectedStatus,
                isPresented: $detailViewModel.showingStatusSelection,
                updateStatus: {_ in
                    self.detailViewModel.updateStatusForSelectedEpisode()
                }
            )
        }
    }
}
