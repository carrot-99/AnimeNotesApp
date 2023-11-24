//  StatusCountView.swift

import SwiftUI

struct StatusCountView: View {
    let label: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text("\(count)")
                .font(.title)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
        .padding(.horizontal)
    }
}
