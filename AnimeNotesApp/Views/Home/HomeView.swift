//  HomeView.swift

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: UserSessionViewModel
    @StateObject private var viewModel = HomeViewModel()
    @State private var verificationMessage: String?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationView {
            Group {
                if session.isAuthenticated {
                    libraryContent
                } else {
                    guestContent
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("ホーム")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if session.isAuthenticated {
                        Button {
                            Task { await viewModel.reload(userId: session.userId) }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(viewModel.isLoading)
                        .accessibilityLabel(Text("再読み込み"))
                    }
                }
            }
            .errorAlert($viewModel.errorMessage)
        }
        .navigationViewStyle(.stack)
    }

    private var libraryContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(session.currentUser?.username ?? "ユーザー")さんのライブラリ")
                        .font(.title3.bold())
                    Text("記録した作品 \(viewModel.totalCount)本")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if !session.isEmailVerified {
                    emailVerificationBanner
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(WatchStatus.tracked) { status in
                        NavigationLink {
                            StatusAnimeListView(status: status)
                        } label: {
                            StatusSummaryCard(status: status, count: viewModel.count(for: status))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        // 他の画面で視聴状況が変わっている可能性があるため、表示のたびに集計し直す
        .onAppear {
            Task { await viewModel.reload(userId: session.userId) }
        }
    }

    private var emailVerificationBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("メールアドレスが未認証です", systemImage: "envelope.badge")
                .font(.subheadline.bold())
                .foregroundColor(.orange)
            Text("登録したアドレスに届いたメールのリンクを開いて認証してください。")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                Button("認証メールを再送") {
                    Task {
                        verificationMessage = await session.resendVerificationEmail() ?? "認証メールを送信しました。"
                    }
                }
                Spacer()
                Button("認証状態を更新") {
                    Task { await session.refreshUser() }
                }
            }
            .font(.caption.bold())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.orange.opacity(0.12))
        )
        .alert(
            verificationMessage ?? "",
            isPresented: Binding(get: { verificationMessage != nil }, set: { if !$0 { verificationMessage = nil } })
        ) {
            Button("OK", role: .cancel) {}
        }
    }

    private var guestContent: some View {
        EmptyStateView(
            systemImage: "books.vertical",
            title: "あなたのアニメライブラリ",
            message: "アカウントを作成すると、作品ごと・話数ごとの視聴状況を記録して、視聴中・視聴済などの一覧をここで確認できます。"
        ) {
            Button("ログイン / アカウント作成") {
                session.exitGuestMode()
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: 320)
        }
        .frame(maxHeight: .infinity)
    }
}

private struct StatusSummaryCard: View {
    let status: WatchStatus
    let count: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                StatusIcon(status: status)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Group {
                    if let count {
                        Text("\(count)")
                    } else {
                        Text("–")
                    }
                }
                .font(.system(size: 32, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundColor(.primary)
                Text(status.label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .accessibilityElement(children: .combine)
    }
}
