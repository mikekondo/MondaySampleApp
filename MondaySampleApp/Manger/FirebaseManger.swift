import FirebaseFirestore
import FirebaseAuth

final class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private init() {}
}

// MARK: Firestore

extension FirebaseManager {
    /// Create
    /// - Parameter post: 投稿データ
    func createPost(post: Post) throws {
        try db
            .collection("posts")
            .addDocument(from: post)
    }

    /// Read
    func readPosts() async throws -> [Post]{
        let postDocuments = try await db
            .collection("posts")
            .getDocuments()
            .documents

        let postList = postDocuments.compactMap {
            try? $0.data(as: Post.self)
        }
        return postList
    }

    /// Update
    func updatePost(post: Post) throws {
        guard let id = post.id else { return }
        try db
            .collection("posts")
            .document(id)
            .setData(from: post)
    }

    /// Delete
    func deletePost(id: String) {        
        db
            .collection("posts")
            .document(id)
            .delete()
    }

    func listenToPostsChange(completion: @escaping ([Post]) -> Void) {
        db
            .collection("posts")
            .addSnapshotListener { querySnapShot, error in
                guard let postDocuments = querySnapShot?.documents else { return }
                let postList = postDocuments.compactMap {
                    try? $0.data(as: Post.self)
                }
                completion(postList)
        }
    }
}

// MARK: FireAuth

extension FirebaseManager {
    func signIn() async throws {
        _ = try await Auth.auth().signInAnonymously()
    }

    func getAuthUid() -> String? {
        Auth.auth().currentUser?.uid
    }

    func deleteAccount() async throws {
        // アカウント削除
        try await Auth.auth().currentUser?.delete()
        // サインアウト
        try Auth.auth().signOut()
        // アプリ内保存全削除
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
}
