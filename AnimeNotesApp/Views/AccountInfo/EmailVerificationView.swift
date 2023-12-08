//  EmailVerificationView.swift

import Foundation
import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var userSessionViewModel: UserSessionViewModel
//    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Text("メールアドレスの認証が必要です。")
            Button("認証メールを再送する") {
                userSessionViewModel.resendVerificationEmail()
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
//        .onReceive(timer) { _ in
//            userSessionViewModel.fetchCurrentUser()
//        }
        .padding()
    }
}
