import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var email = ""
    @Published var isLogin = true
    @Published var user: User?
    @Published var error: String?
    @Published var isLoading = false

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: NSNotification.Name("Logout"), object: nil)
    }

    @objc private func handleLogout() {
        DispatchQueue.main.async {
            self.user = nil
        }
    }

    func performAuth() async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }

        do {
            let authResponse: AuthResponse
            if isLogin {
                authResponse = try await AuthService.shared.login(username: username, password: password)
            } else {
                authResponse = try await AuthService.shared.register(username: username, password: password, email: email.isEmpty ? nil : email)
            }

            DispatchQueue.main.async {
                self.user = authResponse.user
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
