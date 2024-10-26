import FirebaseFirestore

final class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private init() {}
}

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
}
