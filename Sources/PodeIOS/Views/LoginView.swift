import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var backendUrl: String = NetworkService.shared.baseUrl
    @State private var isServerConfigured: Bool = !NetworkService.shared.baseUrl.isEmpty

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // 第一步：服务器配置
                    VStack(alignment: .leading, spacing: 10) {
                        Text("第一步：配置服务器")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        HStack {
                            Image(systemName: "server.rack")
                                .foregroundColor(.gray)
                            TextField("http://your-ip:8080/api/v1", text: $backendUrl)
                                .accessibilityIdentifier("server_url_field")
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: backendUrl) { newValue in
                                    NetworkService.shared.baseUrl = newValue
                                }
                        }
                        Text("请先确保后端 PodeServer 正在运行")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)

                    // 第二步：用户登录
                    VStack(spacing: 20) {
                        Text(viewModel.isLogin ? "第二步：用户登录" : "第二步：用户注册")
                            .font(.headline)
                            .foregroundColor(backendUrl.isEmpty ? .gray : .blue)

                        VStack(spacing: 15) {
                            TextField("用户名", text: $viewModel.username)
                                .accessibilityIdentifier("username_field")
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(backendUrl.isEmpty)

                            if !viewModel.isLogin {
                                TextField("邮箱 (选填)", text: $viewModel.email)
                                    .accessibilityIdentifier("email_field")
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(backendUrl.isEmpty)
                            }

                            SecureField("密码", text: $viewModel.password)
                                .accessibilityIdentifier("password_field")
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(backendUrl.isEmpty)
                        }
                        .padding(.horizontal)

                        Button(action: {
                            Task { await viewModel.performAuth() }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(viewModel.isLogin ? "登录" : "注册")
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(backendUrl.isEmpty ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .accessibilityIdentifier("auth_submit_button")
                        .disabled(backendUrl.isEmpty || viewModel.username.isEmpty || viewModel.password.isEmpty)
                        .padding(.horizontal)

                        Button(action: {
                            viewModel.isLogin.toggle()
                        }) {
                            Text(viewModel.isLogin ? "没有账号？去注册" : "已有账号？去登录")
                                .font(.subheadline)
                        }
                        .accessibilityIdentifier("auth_toggle_button")
                    }
                    .opacity(backendUrl.isEmpty ? 0.5 : 1.0)

                    if let error = viewModel.error {
                        Text(error)
                            .accessibilityIdentifier("login_error_text")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .multilineTextAlignment(.center)
                    }

                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Pode 播客")
            .background(Color(.systemGroupedBackground))
        }
    }
}
