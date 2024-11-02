import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ContentViewModelImpl()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(vm.viewDataList) { viewData in
                        PostCellView(vm: vm, viewData: viewData)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    .animation(.default, value: vm.viewDataList)
                }
            }
            .safeAreaInset(edge: .bottom) {
                // 投稿入力フィールドとボタン
                HStack(spacing: 8) {
                    TextField("いまどうしてる？", text: $vm.message)
                        .padding(12)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
                    Button(action: {
                        Task {
                            await vm.didTapPostButton()
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
            }
        }
        .onAppear {
            Task {
                await vm.viewDidAppear()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // 上部ナビゲーションバー
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
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(viewData.userNameText.prefix(1))
                            .foregroundColor(.white)
                            .font(.headline)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewData.userNameText)
                        .font(.headline)
                    Text(viewData.message)
                        .font(.body)
                    Text(viewData.dateText)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
                    .onTapGesture {}
                }
            }
            if isEditing {
                VStack(spacing: 8) {
                    TextField("編集内容を入力", text: $editMessage)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    Button {
                        Task {
                            await vm.didTapEditDoneButton(id: viewData.id, message: editMessage)
                            isEditing = false
                        }
                    } label: {
                        Text("完了")
                            .font(.callout.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

