import SwiftUI

struct SignInScreenView<VM: SignInViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        VStack(spacing: 24) {
            Text("アカウント登録")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.black)
            VStack(alignment: .leading, spacing: 8) {
                Text("名前")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                TextField("名前を入力してください", text: $vm.userName)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.95), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
            }
            Button {
                Task {
                    await vm.registerUserName(userName: vm.userName)
                }
            } label: {
                Text("登録する")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 16)
                    .background(Color.black.gradient, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 16)
        .fullScreenCover(isPresented: $vm.shouldShowContentView) {
            NavigationStack {
                ContentView()
            }
        }
    }
}

