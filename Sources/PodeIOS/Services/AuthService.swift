import Foundation

class AuthService {
    static let shared = AuthService()
    private init() {}

    func login(username: String, password: String) async throws -> AuthResponse {
        let body = ["username": username, "password": password]
        let bodyData = try JSONEncoder().encode(body)

        let response: ApiResponse<AuthResponse> = try await NetworkService.shared.request(
            endpoint: "/auth/login",
            method: "POST",
            body: bodyData
        )

        if let auth = response.data {
            NetworkService.shared.setToken(auth.token)
            return auth
        } else {
            throw NetworkError.serverError(response.message)
        }
    }

    func register(username: String, password: String, email: String? = nil) async throws -> AuthResponse {
        var body = ["username": username, "password": password]
        if let email = email { body["email"] = email }
        let bodyData = try JSONEncoder().encode(body)

        let response: ApiResponse<AuthResponse> = try await NetworkService.shared.request(
            endpoint: "/auth/register",
            method: "POST",
            body: bodyData
        )

        if let auth = response.data {
            NetworkService.shared.setToken(auth.token)
            return auth
        } else {
            throw NetworkError.serverError(response.message)
        }
    }
}
