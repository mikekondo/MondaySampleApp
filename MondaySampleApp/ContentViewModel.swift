import Foundation

@MainActor protocol ContentViewModel: ObservableObject {
    // life cycle
    func viewDidAppear() async

    // view logic    
    var message: String { get }
    var viewDataList: [ContentViewData] { get }

    // tap logic
    func didTapPostButton() async
    func didTapDeleteButton(id: String) async
    func didTapEditDoneButton(id: String, message: String) async
    func didTapDeleteAccount() async
}

struct ContentViewData: Identifiable, Equatable {
    let id: String
    let message: String
    let userNameText: String
    let dateText: String
    let shouldShowMenu: Bool
}

final class ContentViewModelImpl: ContentViewModel {
    @Published var message: String = ""
    @Published var postListResponse: Result<[Post], Error>?
    let firebaseManager = FirebaseManager.shared
}

extension ContentViewModelImpl {
    private func fetchPostList() async {
        do {
            postListResponse = .success(try await firebaseManager.readPosts())
        } catch {
            postListResponse = .failure(error)
        }
    }
}

// MARK: life cycle logic

extension ContentViewModelImpl {
    func viewDidAppear() async {
        await fetchPostList()
        firebaseManager.listenToPostsChange {
            Task { @MainActor in
                await self.fetchPostList()
            }
        }
    }
}

// MARK: view logic

extension ContentViewModelImpl {
    var viewDataList: [ContentViewData] {
        switch postListResponse {
        case .success(let posts):
            return posts.map {
                makeViewData($0)
            }
        case .failure, .none:
            return []
        }
    }

    private func makeViewData(_ post: Post) -> ContentViewData {
        let userName = UserDefaults.standard.object(forKey: "userName") as? String ?? ""

        // DateFormatterを使って日付を日本語形式に変換
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP") // 日本語ロケールを指定
        dateFormatter.dateStyle = .medium  // 日付部分のスタイル
        dateFormatter.timeStyle = .short   // 時刻部分のスタイル

        let dateText = dateFormatter.string(from: post.date)

        return .init(
            id: post.id ?? UUID().uuidString,
            message: post.message,
            userNameText: post.userName + "さんの投稿",
            dateText: dateText,
            shouldShowMenu: post.userName == userName
        )
    }

}

// MARK: tap logic

extension ContentViewModelImpl {
    func didTapPostButton() async {
        guard let userName = UserDefaults.standard.object(forKey: "userName") as? String else { return}
        do {
            try firebaseManager.createPost(post: .init(userName: userName, message: message, date: Date()))
            message = ""
            await fetchPostList()
        } catch {
            print(error)
        }
    }

    func didTapDeleteButton(id: String) async {
        firebaseManager.deletePost(id: id)
        await fetchPostList()
    }

    func didTapEditDoneButton(id: String, message: String) async {
        switch postListResponse {
        case .success(let posts):
            guard let post = posts.first(where: { $0.id == id } ) else { return }
            var editPost = post
            editPost.message = message
            try? firebaseManager.updatePost(post: editPost)
            await fetchPostList()
        case .failure, .none:
            return
        }
    }

    func didTapDeleteAccount() async {
        try? await firebaseManager.deleteAccount()
    }
}
