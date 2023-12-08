//  HomeView.swift

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userSessionViewModel: UserSessionViewModel
    @StateObject private var viewModel = HomeViewModel(authService: AuthenticationService())
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if userSessionViewModel.isUserAuthenticated {
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
                } else {
                    // アカウント未作成の場合、メッセージを表示
                    Group {
                        Text("アカウント未作成ユーザーは機能が制限されます。")
                        Text("アカウントを作成することで、各アニメ、各話の視聴状況を記録できるようになります。")
                        Text("例えば、この画面では視聴状況ごとのアニメリストを取得することができます。")
                    }
                    .font(.headline)
                    
                    // アカウント作成への導線
                    NavigationLink(destination: CreateAccountView()) {
                        SettingsButtonLabel(title: "アカウント作成", color: Color.green)
                    }
                    .padding()
                }
            }
            .navigationTitle("ホーム")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.refreshStatusCounts) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .background(colorScheme == .dark ? Color(white: 0.05) : Color(UIColor.systemGroupedBackground))
        }
        .onAppear(perform: viewModel.refreshStatusCounts)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
