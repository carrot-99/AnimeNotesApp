//  FirestoreService.swift

import FirebaseFirestore
import FirebaseFirestoreSwift

enum FirestoreCollection {
    static let animes = "animes"
    static let users = "users"
    static let watchingHistory = "userWatchingHistory"
    static let episodesHistory = "episodesHistory"
}

/// Firestore アクセスの共通処理
class FirestoreService {
    /// Firestore の `in` クエリに渡せる値の上限
    static let inQueryLimit = 30
    /// 1 回のバッチ書き込みの上限（500）に余裕を持たせた値
    static let batchLimit = 450

    let db: Firestore

    init(database: Firestore = Firestore.firestore()) {
        self.db = database
    }

    func documents<T: Decodable>(_ query: Query, as type: T.Type) async throws -> [T] {
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: T.self) }
    }

    func set<T: Encodable>(_ value: T, at reference: DocumentReference, merge: Bool = false) async throws {
        let data = try Firestore.Encoder().encode(value)
        try await reference.setData(data, merge: merge)
    }

    /// 書き込み数の上限を超えないよう分割してバッチ処理する
    func commitInBatches<Item>(_ items: [Item], apply: (WriteBatch, Item) throws -> Void) async throws {
        for chunk in items.chunked(into: Self.batchLimit) {
            let batch = db.batch()
            for item in chunk {
                try apply(batch, item)
            }
            try await batch.commit()
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
