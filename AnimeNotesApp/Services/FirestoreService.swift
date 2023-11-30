//  FirestoreService.swift

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import FirebaseAuth

class FirestoreService: FirestoreServiceProtocol {
    let db: Firestore
    
    init(database: Firestore = Firestore.firestore()) {
        self.db = database
    }
    
    func performQuery<T: Decodable>(_ query: Query, decodingType: T.Type) -> AnyPublisher<[T], Error> {
        Future<[T], Error> { promise in
            query.getDocuments { snapshot, error in
                if let error = error {
                    print("getDataError")
                    promise(.failure(error))
                } else if let snapshot = snapshot {
                    let results = snapshot.documents.compactMap { document -> T? in
                        let data = document.data()
                        return try? document.data(as: T.self)
                    }
                    promise(.success(results))
                } else {
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func setData<T: Encodable>(_ documentReference: DocumentReference, for data: T) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            do {
                let dataDict = try Firestore.Encoder().encode(data)
                documentReference.setData(dataDict) { error in
                    if let error = error {
                        print("Error setting data: \(error.localizedDescription)")
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                print("Error encoding data: \(error.localizedDescription)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func updateData(_ documentReference: DocumentReference, data: [String: Any]) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            print("FirestoreService:updateData")
            documentReference.updateData(data) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
