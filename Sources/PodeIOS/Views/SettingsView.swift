import SwiftUI

struct SettingsView: View {
    @State private var backendUrl = NetworkService.shared.baseUrl
    @State private var showingSaveAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("服务器配置"), footer: Text("默认地址为 http://localhost:8080/api/v1")) {
                    TextField("后端 URL", text: $backendUrl)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button("保存配置") {
                        NetworkService.shared.baseUrl = backendUrl
                        showingSaveAlert = true
                    }
                }
                
                Section(header: Text("账号")) {
                    Button("退出登录", role: .destructive) {
                        NetworkService.shared.clearToken()
                        NotificationCenter.default.post(name: NSNotification.Name("Logout"), object: nil)
                    }
                }
            }
            .navigationTitle("设置")
            .alert("保存成功", isPresented: $showingSaveAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("后端地址已更新为：\(backendUrl)")
            }
        }
    }
}
