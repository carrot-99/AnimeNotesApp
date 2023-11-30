// ViewComponents.swift

import SwiftUI

struct SettingsButtonLabel: View {
    var title: String
    var color: Color

    var body: some View {
        Text(title)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(10)
    }
}
