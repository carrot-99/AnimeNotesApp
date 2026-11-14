//  LoginView.swift

import SwiftUI

struct LoginView: View {
    private enum Field { case email, password }

    @EnvironmentObject private var session: UserSessionViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isShowingCreateAccount = false
    @State private var isShowingPasswordReset = false
    @FocusState private var focusedField: Field?

    private var canSubmit: Bool {
        Validation.isValidEmail(email) && !password.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header

                VStack(spacing: 12) {
                    FormTextField(title: "メールアドレス", text: $email, kind: .email) {
                        focusedField = .password
                    }
                    .focused($focusedField, equals: .email)

                    FormTextField(title: "パスワード", text: $password, kind: .password(isNew: false), submitLabel: .go) {
                        submit()
                    }
                    .focused($focusedField, equals: .password)

                    if let errorMessage {
                        InlineMessage(text: errorMessage)
                    }

                    PrimaryButton(title: "ログイン", isLoading: session.isProcessing, action: submit)
                        .disabled(!canSubmit)
                        .padding(.top, 4)

                    Button("パスワードをお忘れの方") {
                        isShowingPasswordReset = true
                    }
                    .font(.footnote)
                    .padding(.top, 4)
                }

                VStack(spacing: 12) {
                    divider

                    Button {
                        errorMessage = nil
                        isShowingCreateAccount = true
                    } label: {
                        Text("新規アカウント作成")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.bordered)

                    Button("アカウントを作成せずに利用する") {
                        session.enterGuestMode()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                }
            }
            .padding(24)
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .dismissKeyboardOnTap()
        .sheet(isPresented: $isShowingCreateAccount) {
            CreateAccountView()
        }
        .sheet(isPresented: $isShowingPasswordReset) {
            PasswordResetModalView(initialEmail: email)
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "play.tv.fill")
                .font(.system(size: 52))
                .foregroundColor(.accentColor)
                .padding(.top, 40)
            Text("アニメのーと")
                .font(.largeTitle.bold())
            Text("観たアニメを、話数ごとに記録しよう")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var divider: some View {
        HStack {
            VStack { Divider() }
            Text("または")
                .font(.caption)
                .foregroundColor(.secondary)
            VStack { Divider() }
        }
    }

    private func submit() {
        guard canSubmit, !session.isProcessing else { return }
        focusedField = nil
        Task {
            errorMessage = await session.signIn(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
        }
    }
}
