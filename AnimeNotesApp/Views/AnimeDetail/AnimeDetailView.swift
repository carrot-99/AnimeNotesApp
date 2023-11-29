//  AnimeDetailView.swift

import SwiftUI
import FirebaseAuth

struct AnimeDetailView: View {
    var anime: UserAnime
    @ObservedObject var ViewModel: AnimeDetailViewModel
    
    var showingStatusSelectionBinding: Binding<Bool> {
        Binding(
            get: { self.ViewModel.showingStatusSelection },
            set: { self.ViewModel.showingStatusSelection = $0 }
        )
    }

    var selectedStatusBinding: Binding<Int> {
        Binding(
            get: { self.ViewModel.selectedStatus },
            set: { self.ViewModel.selectedStatus = $0 }
        )
    }
    
    init(anime: UserAnime, ViewModel: AnimeDetailViewModel) {
        self.anime = anime
        self.ViewModel = ViewModel
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
                
                if ViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                } else {
                    ForEach(ViewModel.episodes, id: \.id) { episode in
                        HStack {
                            Image(systemName: iconForStatus(episode.status))
                                .onTapGesture {
                                    ViewModel.selectEpisode(episode)
                                }
                            Text("エピソード \(episode.episode_num)")
                        }
                    }
                }
            }
            .onAppear {
                ViewModel.fetchEpisodes(for: anime)
            }
            .padding()
        }
        .navigationBarTitle(Text(anime.title), displayMode: .inline)
        .sheet(isPresented: $ViewModel.showingStatusSelection) {
            StatusSelectionModalView(
                selectedStatus: $ViewModel.selectedStatus,
                isPresented: $ViewModel.showingStatusSelection,
                updateStatus: {_ in
                    self.ViewModel.updateStatusForSelectedEpisode()
                }
            )
        }
    }
}
