//  ContentView.swift

import Foundation
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel

    var body: some View {
        if userSessionViewModel.isUserAuthenticated {
            MainTabView()
        } else {
            LoginView()
        }
    }
}
