//  MainTabView.swift

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userSessionVM: UserSessionViewModel
    
    var body: some View {
        TabView {
            SeasonListView(seasonListVM: SeasonListViewModel())
                .tabItem {
                    Label("リスト", systemImage: "list.dash")
                }
            
            SearchView()
                .tabItem {
                    Label("検索", systemImage: "magnifyingglass")
                }
            
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
        }
    }
}
