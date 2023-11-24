//  SearchBarView.swift

import Foundation
import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var onSearch: () -> Void

    var body: some View {
        HStack {
            TextField("タイトルを検索", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: onSearch) {
                Text("検索")
            }
        }
        .padding()
    }
}
