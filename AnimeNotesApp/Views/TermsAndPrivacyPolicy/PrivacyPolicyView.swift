// PrivacyPolicyView.swift

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    Text("1. はじめに\nAnimeNotes（以下「本サービス」といいます）は、ユーザーのプライバシーを尊重し、個人情報の保護に努めます。本プライバシーポリシーでは、本サービスにおける個人情報の取り扱いについて説明します。")
                        .padding(.bottom)
                    Text("2. 収集する情報\nアカウント情報：メールアドレス、ユーザー名など\n利用データ：視聴履歴、アニメの評価、コメントなど\nアクセスログ：利用時のIPアドレス、ブラウザ情報など")
                        .padding(.bottom)
                    Text("3. 情報の利用目的\n収集した情報は、以下の目的で利用します。\nサービスの提供および改善\nユーザーサポート\n新機能の開発\n法令遵守")
                        .padding(.bottom)
                }
                Group {
                    Text("4. 情報の共有\n運営者は、以下の場合を除き、ユーザーの個人情報を第三者に開示または共有しません。\nユーザーの同意がある場合\n法令に基づく場合\nユーザーの権利、財産、安全を保護するため必要な場合")
                        .padding(.bottom)
                    Text("5. 情報の保護\n運営者は、個人情報の安全性を保護するため、適切な物理的、技術的、管理的な措置を講じます。")
                        .padding(.bottom)
                    Text("6. アクセスおよび訂正\nユーザーは、自己の個人情報にアクセスし、不正確な情報を訂正する権利があります。")
                        .padding(.bottom)
                }
                Group {
                    Text("7. プライバシーポリシーの変更\n運営者は、必要に応じて本ポリシーを変更することがあります。変更があった場合は、本サービス上で通知します。")
                        .padding(.bottom)
                    Text("8. お問い合わせ\n本プライバシーポリシーに関するお問い合わせは、[carrot99.official@gmail.com]までお願いします。")
                }
            }
            .padding()
        }
        .navigationTitle("プライバシーポリシー")
    }
}
