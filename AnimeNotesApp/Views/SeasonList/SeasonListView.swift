// SeasonListView.swift

import SwiftUI

struct SeasonListView: View {
    @StateObject var seasonListVM: SeasonListViewModel

    var body: some View {
        NavigationStack {
            List(seasonListVM.seasons, id: \.self) { season in
                Button(season) {
                    seasonListVM.selectSeason(season)
                }
            }
            .navigationTitle("クール選択")
            .alert(isPresented: $seasonListVM.hasError) {
                Alert(
                    title: Text("Error"),
                    message: Text(seasonListVM.errorMessage),
                    dismissButton: .default(Text("OK")) {
                        seasonListVM.dismissError()
                })
            }
            .navigationDestination(isPresented: $seasonListVM.navigateToAnimeList) {
                seasonListVM.navigateToAnimeDetail()
            }
        }
    }
}
