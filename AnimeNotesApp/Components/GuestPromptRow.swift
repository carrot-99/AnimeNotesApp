//  GuestPromptRow.swift

import SwiftUI

/// ゲスト利用中に、アカウント作成でできることを案内する行
struct GuestPromptRow: View {
    @EnvironmentObject private var session: UserSessionViewModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.title2)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text("ログインで視聴記録")
                    .font(.subheadline.bold())
                Text("作品・話数ごとに記録できます")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 0)
            Button("ログイン") {
                session.exitGuestMode()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
}
