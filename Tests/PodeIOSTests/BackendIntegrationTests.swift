import XCTest
@testable import PodeIOS

final class BackendIntegrationTests: XCTestCase {
    private let backendBaseURL = "http://127.0.0.1:8080/api/v1"

    override func setUp() async throws {
        try await super.setUp()
        try await requireBackend()
        NetworkService.shared.baseUrl = backendBaseURL
        NetworkService.shared.clearToken()
    }

    func testRegisterSearchSubscribeAndProgressFlow() async throws {
        let unique = Int(Date().timeIntervalSince1970)
        let username = "it_\(unique)"
        let password = "Passw0rd_\(unique)"

        let auth = try await AuthService.shared.register(username: username, password: password)
        XCTAssertFalse(auth.token.isEmpty)
        XCTAssertEqual(auth.user.username, username)

        let podcasts = try await PodcastService.shared.searchPodcasts(keyword: "bible")
        XCTAssertFalse(podcasts.isEmpty)
        let podcast = try XCTUnwrap(podcasts.first)

        try await PodcastService.shared.subscribe(podcastId: podcast.id)
        let subscriptions = try await PodcastService.shared.getSubscriptions(page: 1)
        XCTAssertTrue(subscriptions.contains(where: { $0.podcastId == podcast.id }))

        try await PodcastService.shared.unsubscribe(podcastId: podcast.id)

        let (timeline, _) = try await PodcastService.shared.getTimeline(page: 1, pageSize: 1)
        if let first = timeline.first {
            try await PodcastService.shared.updateProgress(episodeId: first.episodeId, position: 7, completed: false)
        }
    }

    private func requireBackend() async throws {
        guard let url = URL(string: "http://127.0.0.1:8080/health") else {
            throw XCTSkip("Invalid backend health URL")
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw XCTSkip("Backend is not reachable at 127.0.0.1:8080")
        }
    }
}
