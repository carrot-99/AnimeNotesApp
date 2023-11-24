//  FirestoreServiceProtocol.swift

import Combine
import FirebaseFirestore

protocol FirestoreServiceProtocol {
    func performQuery<T: Decodable>(_ query: Query, decodingType: T.Type) -> AnyPublisher<[T], Error>
    func setData<T: Encodable>(_ documentReference: DocumentReference, for data: T) -> AnyPublisher<Void, Error>
    func updateData(_ documentReference: DocumentReference, data: [String: Any]) -> AnyPublisher<Void, Error>
}
