//  EmptyStateView.swift

import SwiftUI

/// データがないときの案内表示
struct EmptyStateView<Actions: View>: View {
    let systemImage: String
    let title: String
    var message: String?
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            actions()
                .padding(.top, 8)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}

extension EmptyStateView where Actions == EmptyView {
    init(systemImage: String, title: String, message: String? = nil) {
        self.init(systemImage: systemImage, title: title, message: message, actions: { EmptyView() })
    }
}
