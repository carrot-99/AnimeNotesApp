//  HomeView.swift

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel(authService: AuthenticationService())

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ForEach(UserAnimeStatus.allCases, id: \.self) { status in
                    NavigationLink(
                        destination: StatusAnimeListView(
                            viewModel: viewModel.getOrCreateStatusViewModel(for: status.rawValue)
                        )
                    ) {
                        StatusCountView(label: status.description, count: viewModel.count(for: status))
                    }
                }
                Spacer()
            }
            .navigationTitle("ホーム")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.refreshStatusCounts) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear(perform: viewModel.refreshStatusCounts)
    }
}
