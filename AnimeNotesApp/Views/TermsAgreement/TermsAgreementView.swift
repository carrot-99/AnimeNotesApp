import SwiftUI

struct TermsAgreementView: View {
    @Binding var isTermsAgreed: Bool
    @State private var localIsTermsAgreed: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                // タイトルと説明文
                VStack(alignment: .leading, spacing: 10) {
                    Text("利用規約とプライバシーポリシーを確認し、同意をお願いします。")
                        .font(.headline)
                        .padding(.bottom, 5)

                    // 利用規約とプライバシーポリシーへのリンク
                    HStack {
                        NavigationLink(destination: TermsView()) {
                            Text("利用規約")
                                .foregroundColor(.blue)
                        }

                        Spacer()

                        NavigationLink(destination: PrivacyPolicyView()) {
                            Text("プライバシーポリシー")
                                .foregroundColor(.blue)
                        }
                    }
                }

                Spacer()

                // 同意するトグル
                Toggle("同意する", isOn: $localIsTermsAgreed)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .padding(.vertical, 20)

                // 次へボタン
                Button("次へ") {
                    isTermsAgreed = localIsTermsAgreed
                }
                .disabled(!localIsTermsAgreed)
                .padding(.bottom, 20)
            }
            .padding()
        }
        .onAppear {
            localIsTermsAgreed = isTermsAgreed
        }
    }
}
