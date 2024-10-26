import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct MondaySampleAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var vm = SignInViewModelImpl()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if vm.alreadyRegisterUserName {
                    ContentView()
                } else {
                    SignInScreenView(vm: vm)
             }
            }
        }
    }
}
