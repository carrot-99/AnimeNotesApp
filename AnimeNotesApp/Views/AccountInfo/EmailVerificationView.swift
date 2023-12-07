//  EmailVerificationView.swift

import Foundation
import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
    @Environment(\.presentationMode) var presentationMode
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Text("メールアドレスの認証が必要です。")
            Button("認証メールを再送する") {
                userSessionViewModel.resendVerificationEmail()
            }
            .padding()
            
            // 前の画面に戻るボタン
            Button("メールアドレスを修正する") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            
            if let message = userSessionViewModel.updateSuccessMessage {
                Text(message)
                    .foregroundColor(.green)
            }
            if let errorMessage = userSessionViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .onReceive(timer) { _ in
            userSessionViewModel.fetchCurrentUser()
        }
        .padding()
    }
}
