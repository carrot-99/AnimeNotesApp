// SeasonListView.swift

import SwiftUI

struct SeasonListView: View {
    @StateObject var seasonListVM: SeasonListViewModel

    var body: some View {
        NavigationView {
            List(seasonListVM.seasons, id: \.self) { season in
                NavigationLink(destination: seasonListVM.navigateToAnimeDetail(season: season)){
                    ListItemView(title: season, iconName: nil)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("クール選択")
            .alert(isPresented: $seasonListVM.hasError) {
                Alert(
                    title: Text("Error"),
                    message: Text(seasonListVM.errorMessage),
                    dismissButton: .default(Text("OK")) {
                        seasonListVM.dismissError()
                    }
                )
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}
