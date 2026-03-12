import Foundation

enum NetworkError: Error {
    case invalidUrl
    case noData
    case decodingError
    case serverError(String)
}

class NetworkService {
    static let shared = NetworkService()
    
    private var _baseUrl: String? {
        get { UserDefaults.standard.string(forKey: "backend_url") }
        set { UserDefaults.standard.set(newValue, forKey: "backend_url") }
    }

    var baseUrl: String {
        get { _baseUrl ?? "http://localhost:8080/api/v1" }
        set { _baseUrl = newValue }
    }

    private init() {}

    private var token: String? {
        get { UserDefaults.standard.string(forKey: "auth_token") }
        set { UserDefaults.standard.set(newValue, forKey: "auth_token") }
    }

    func setToken(_ token: String) {
        self.token = token
    }

    func clearToken() {
        self.token = nil
    }

    private static let iso8601WithFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let legacyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)

            if let date = Self.iso8601WithFractional.date(from: raw)
                ?? Self.iso8601.date(from: raw)
                ?? Self.legacyDateFormatter.date(from: raw) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(raw)")
        }
        return decoder
    }

    func request<T: Decodable>(endpoint: String, method: String = "GET", body: Data? = nil) async throws -> ApiResponse<T> {
        guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
            throw NetworkError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = self.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }

        if !(200...299).contains(httpResponse.statusCode) {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode), \(errorMsg)")
        }

        let decoder = Self.makeDecoder()

        do {
            return try decoder.decode(ApiResponse<T>.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
}
