import Foundation
import FirebaseFirestore

struct Post: Codable {
    @DocumentID var id: String?
    let userName: String
    let message: String
    // TODO
}
