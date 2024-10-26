import FirebaseFirestore

final class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private init() {}
}

extension FirebaseManager {
    // TODO: CRUD処理
    
}
