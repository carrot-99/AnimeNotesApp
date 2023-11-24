//  IdentifiableError.swift

import Foundation

struct IdentifiableError: Error, Identifiable {
    let id: String = UUID().uuidString
    let message: String
}
