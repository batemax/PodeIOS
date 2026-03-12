import SwiftUI

@main
struct PodeIOSApp: App {
    @StateObject var authViewModel = AuthViewModel()

    init() {
        let processInfo = ProcessInfo.processInfo
        let defaults = UserDefaults.standard

        if processInfo.arguments.contains("-ui-test-reset") {
            defaults.removeObject(forKey: "auth_token")
            defaults.removeObject(forKey: "backend_url")
        }

        if let backend = processInfo.environment["UI_TEST_BACKEND_URL"], !backend.isEmpty {
            defaults.set(backend, forKey: "backend_url")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView(authViewModel: authViewModel)
        }
    }
}
