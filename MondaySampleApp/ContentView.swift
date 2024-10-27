import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ContentViewModelImpl()

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(vm.viewDataList) { viewData in
                    PostCellView(vm: vm, viewData: viewData)
                }
                .animation(.default, value: vm.viewDataList)
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            Task {
                await vm.viewDidAppear()
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 8) {
                TextField("メッセージを入力", text: $vm.message)
                    .textFieldStyle(.roundedBorder)
                    .padding(.vertical, 8)
                Button(action: {
                    Task {
                        await vm.didTapPostButton()
                    }
                }) {
                    Text("投稿")
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("投稿リスト")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await vm.didTapDeleteAccount()
                    }
                } label: {
                    Text("アカウント削除")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Text(vm.userName)
                    .font(.title3.bold())
                    .foregroundStyle(Color.black)
            }
        }
    }
}

struct PostCellView<VM: ContentViewModel>: View {
    @State private var isEditing = false
    @State private var editMessage = ""
    @ObservedObject var vm: VM
    let viewData: ContentViewData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                if isEditing {
                    TextField("編集内容を入力", text: $editMessage)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewData.userNameText)
                            .font(.body.bold())
                        Text(viewData.message)
                            .font(.body)
                        Text(viewData.dateText)
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if viewData.shouldShowMenu {
                    Menu {
                        Button("編集") {
                            isEditing = true
                            editMessage = viewData.message
                        }
                        Button("削除", role: .destructive) {
                            Task {
                                await vm.didTapDeleteButton(id: viewData.id)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                }
            }
            if isEditing {
                Button("完了") {
                    Task {
                        await vm.didTapEditDoneButton(id: viewData.id, message: editMessage)
                        isEditing = false
                    }
                }
                .padding(.top, 4)
                .foregroundColor(.blue)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
