// StatusSelectionModalView.swift

import SwiftUI

struct StatusSelectionModalView: View {
    @Binding var selectedStatus: Int
    @Binding var isPresented: Bool
    var updateStatus: (Int) -> Void
    let statuses = [
        (0, "未視聴", "eye.slash"),
        (1, "視聴中", "play.circle"),
        (2, "視聴中断", "pause.circle"),
        (3, "視聴済", "checkmark.circle"),
        (4, "視聴予定", "calendar.circle")
    ]
    
    var body: some View {
        NavigationView {
            List(statuses, id: \.0) { status in
                Button(action: {
                    self.selectedStatus = status.0
                    self.updateStatus(status.0)
                }) {
                    HStack {
                        Image(systemName: status.2)
                            .foregroundColor(.gray)
                        Text(status.1)
                            .foregroundColor(.primary)
                        Spacer()
                        if status.0 == selectedStatus {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationBarTitle("視聴状況選択", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        self.isPresented = false
                    }
                }
            }
        }
    }
}
