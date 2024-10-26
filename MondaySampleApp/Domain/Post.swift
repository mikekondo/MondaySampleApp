import Foundation
import FirebaseFirestore

struct Post: Codable {
    @DocumentID var id: String?
    var userName: String
    var message: String
    // TODO: userIdも入れる？
}
