//  TermsAgreementView.swift

import SwiftUI

/// 初回起動時の利用規約・プライバシーポリシーへの同意画面
struct TermsAgreementView: View {
    @Binding var isTermsAgreed: Bool
    @State private var hasCheckedAgreement = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "play.tv.fill")
                        .font(.system(size: 52))
                        .foregroundColor(.accentColor)
                    Text("アニメのーとへようこそ")
                        .font(.title2.bold())
                    Text("ご利用の前に、利用規約とプライバシーポリシーをご確認ください。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 0) {
                    documentLink(title: "利用規約", systemImage: "doc.text") { TermsView() }
                    Divider().padding(.leading, 48)
                    documentLink(title: "プライバシーポリシー", systemImage: "hand.raised") { PrivacyPolicyView() }
                }
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )

                Spacer()

                Toggle("利用規約とプライバシーポリシーに同意する", isOn: $hasCheckedAgreement)
                    .font(.subheadline)

                Button("同意して始める") {
                    isTermsAgreed = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!hasCheckedAgreement)
            }
            .padding(24)
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }

    private func documentLink<Destination: View>(
        title: String,
        systemImage: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(.accentColor)
                    .frame(width: 24)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
