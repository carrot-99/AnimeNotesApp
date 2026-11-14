//  MainTabView.swift

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            SeasonListView()
                .tabItem { Label("リスト", systemImage: "calendar") }

            SearchView()
                .tabItem { Label("検索", systemImage: "magnifyingglass") }

            HomeView()
                .tabItem { Label("ホーム", systemImage: "house") }

            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape") }
        }
    }
}
