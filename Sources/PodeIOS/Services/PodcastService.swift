import Foundation

class PodcastService {
    static let shared = PodcastService()
    private init() {}

    func getTimeline(page: Int = 1, pageSize: Int = 20) async throws -> ([TimelineItem], Pagination?) {
        let response: ApiResponse<[TimelineItem]> = try await NetworkService.shared.request(
            endpoint: "/timeline?page=\(page)&page_size=\(pageSize)"
        )
        return (response.data ?? [], response.pagination)
    }

    func searchPodcasts(keyword: String, page: Int = 1) async throws -> [Podcast] {
        let keywordEncoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let response: ApiResponse<[Podcast]> = try await NetworkService.shared.request(
            endpoint: "/podcasts/search?keyword=\(keywordEncoded)&page=\(page)"
        )
        return response.data ?? []
    }

    func addPodcast(rssUrl: String) async throws -> Podcast {
        let body = ["rss_url": rssUrl]
        let bodyData = try JSONEncoder().encode(body)

        let response: ApiResponse<Podcast> = try await NetworkService.shared.request(
            endpoint: "/podcasts",
            method: "POST",
            body: bodyData
        )

        if let podcast = response.data {
            return podcast
        } else {
            throw NetworkError.serverError(response.message)
        }
    }

    func getSubscriptions(page: Int = 1) async throws -> [Subscription] {
        let response: ApiResponse<[Subscription]> = try await NetworkService.shared.request(
            endpoint: "/subscriptions?page=\(page)"
        )
        return response.data ?? []
    }

    func subscribe(podcastId: Int) async throws {
        let _: ApiResponse<Subscription> = try await NetworkService.shared.request(
            endpoint: "/subscriptions/\(podcastId)",
            method: "POST"
        )
    }

    func unsubscribe(podcastId: Int) async throws {
        let _: ApiResponse<SubscriptionActionData> = try await NetworkService.shared.request(
            endpoint: "/subscriptions/\(podcastId)",
            method: "DELETE"
        )
    }

    func updateProgress(episodeId: Int, position: Int, completed: Bool) async throws {
        let body: [String: Any] = ["position": position, "completed": completed]
        let bodyData = try JSONSerialization.data(withJSONObject: body)

        let _: ApiResponse<PlayProgress> = try await NetworkService.shared.request(
            endpoint: "/episodes/\(episodeId)/progress",
            method: "PUT",
            body: bodyData
        )
    }
}
