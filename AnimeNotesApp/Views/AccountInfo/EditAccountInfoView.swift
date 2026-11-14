// EditAccountInfoView.swift

import SwiftUI

struct EditAccountInfoView: View {
    @EnvironmentObject private var session: UserSessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var errorMessage: String?
    @FocusState private var isFocused: Bool

    private var canSave: Bool {
        Validation.isValidUsername(username)
            && username.trimmingCharacters(in: .whitespacesAndNewlines) != session.currentUser?.username
    }

    var body: some View {
        Form {
            Section {
                TextField("ユーザー名", text: $username)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit(save)
            } header: {
                Text("ユーザー名")
            } footer: {
                if let errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                } else {
                    Text("\(Validation.usernameMaxLength)文字以内（\(username.count)/\(Validation.usernameMaxLength)）")
                        .foregroundColor(username.count > Validation.usernameMaxLength ? .red : .secondary)
                }
            }
        }
        .navigationTitle("ユーザー名の変更")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if session.isProcessing {
                    ProgressView()
                } else {
                    Button("保存", action: save)
                        .disabled(!canSave)
                }
            }
        }
        .onAppear {
            username = session.currentUser?.username ?? ""
            isFocused = true
        }
    }

    private func save() {
        guard canSave, !session.isProcessing else { return }
        Task {
            errorMessage = await session.updateUsername(username)
            if errorMessage == nil {
                Haptics.success()
                dismiss()
            }
        }
    }
}
