import FirebaseCore
import FirebaseAuth

@MainActor protocol SignInViewModel: ObservableObject {
    var userName: String { get set }
    var shouldShowContentView: Bool { get set }
    func registerUserName(userName: String) async
    var alreadyRegisterUserName: Bool { get }
}

protocol SignInTransitionDelegate: AnyObject {
    func transitionToUserSetting()
}

class SignInViewModelImpl: SignInViewModel {
    @Published var userName: String = ""
    @Published var shouldShowContentView: Bool = false
    let firebaseManager = FirebaseManager.shared


    func registerUserName(userName: String) async {
        do {
            try await firebaseManager.signIn()
            shouldShowContentView = true
            UserDefaults.standard.set(userName, forKey: "userName")
        } catch {
            print(error)
        }
    }

    var alreadyRegisterUserName: Bool {
        let userName = UserDefaults.standard.object(forKey: "userName")
        return userName != nil
    }
}

