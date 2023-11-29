//  TermsAgreementView.swift

import SwiftUI

struct TermsAgreementView: View {
    @Binding var isTermsAgreed: Bool
    @State private var navigateToLogin = false

    var body: some View {
        NavigationStack {
            VStack {
                // プライバシーポリシーと利用規約へのリンクやテキストを表示
                Text("利用規約とプライバシーポリシーに同意してください。")
                
                // 同意するチェックボックス
                Toggle("同意する", isOn: $isTermsAgreed)
                
                // ボタンは単にナビゲーションのトリガーとして機能します
                Button("次へ") {
                    if isTermsAgreed {
                        navigateToLogin = true
                    }
                }
                .disabled(!isTermsAgreed) // 同意がない場合はボタンを無効化
                
                // NavigationLink はビュー内に隠れた状態で存在します
                NavigationLink(
                    destination: LoginView(),
                    isActive: $navigateToLogin
                ) { EmptyView() }
            }
            .padding()
        }
    }
}
