import Foundation

struct User: Decodable, Identifiable {
    let id: Int
    let username: String
    let email: String?
    let avatar: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, username, email, avatar
        case createdAt = "created_at"
    }
}

struct AuthResponse: Decodable {
    let token: String
    let user: User
}

struct ApiResponse<T: Decodable>: Decodable {
    let code: Int
    let message: String
    let data: T?
    let pagination: Pagination?
}

struct Pagination: Decodable {
    let page: Int
    let pageSize: Int
    let total: Int
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page
        case pageSize = "page_size"
        case total
        case totalPages = "total_pages"
    }
}

struct Podcast: Decodable, Identifiable {
    let id: Int
    let rssUrl: String
    let title: String
    let description: String
    let imageUrl: String
    let author: String
    let link: String
    let category: String
    let lastBuildDate: String
    let createdAt: Date?
    let episodes: [Episode]?
}

extension Podcast {
    enum CodingKeys: String, CodingKey {
        case id, title, description, author, link, category
        case rssUrl = "rss_url"
        case imageUrl = "image_url"
        case lastBuildDate = "last_build_date"
        case lastRefreshedAt = "last_refreshed_at"
        case createdAt = "created_at"
        case episodes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        rssUrl = try container.decodeIfPresent(String.self, forKey: .rssUrl) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        author = try container.decodeIfPresent(String.self, forKey: .author) ?? ""
        link = try container.decodeIfPresent(String.self, forKey: .link) ?? ""
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
        if let legacy = try container.decodeIfPresent(String.self, forKey: .lastBuildDate) {
            lastBuildDate = legacy
        } else {
            lastBuildDate = try container.decodeIfPresent(String.self, forKey: .lastRefreshedAt) ?? ""
        }
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        episodes = try container.decodeIfPresent([Episode].self, forKey: .episodes)
    }
}

struct Episode: Decodable, Identifiable {
    let id: Int
    let podcastId: Int
    let guid: String
    let title: String
    let description: String
    let audioUrl: String
    let audioType: String
    let audioSize: Int
    let audioDuration: Int
    let pubDate: String
    let imageUrl: String
    let createdAt: Date?
}

extension Episode {
    enum CodingKeys: String, CodingKey {
        case id, guid, title, description
        case podcastId = "podcast_id"
        case audioUrl = "audio_url"
        case audioType = "audio_type"
        case audioSize = "audio_size"
        case audioDuration = "audio_duration"
        case duration
        case fileSize = "file_size"
        case mimeType = "mime_type"
        case pubDate = "pub_date"
        case imageUrl = "image_url"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        podcastId = try container.decode(Int.self, forKey: .podcastId)
        guid = try container.decodeIfPresent(String.self, forKey: .guid) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        audioUrl = try container.decodeIfPresent(String.self, forKey: .audioUrl) ?? ""
        audioType = try container.decodeIfPresent(String.self, forKey: .audioType)
            ?? (try container.decodeIfPresent(String.self, forKey: .mimeType) ?? "")
        audioSize = try container.decodeIfPresent(Int.self, forKey: .audioSize)
            ?? (try container.decodeIfPresent(Int.self, forKey: .fileSize) ?? 0)
        audioDuration = try container.decodeIfPresent(Int.self, forKey: .audioDuration)
            ?? (try container.decodeIfPresent(Int.self, forKey: .duration) ?? 0)
        pubDate = try container.decodeIfPresent(String.self, forKey: .pubDate) ?? ""
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
}

struct TimelineItem: Decodable, Identifiable {
    var id: Int { episodeId }
    let podcastId: Int
    let podcastTitle: String
    let podcastImage: String
    let episodeId: Int
    let episodeTitle: String
    let episodeDescription: String
    let episodeAudioUrl: String
    let episodePubDate: String
}

extension TimelineItem {
    enum CodingKeys: String, CodingKey {
        case podcastId = "podcast_id"
        case podcastTitle = "podcast_title"
        case podcastImage = "podcast_image"
        case episodeId = "episode_id"
        case episodeTitle = "episode_title"
        case episodeDescription = "episode_description"
        case episodeAudioUrl = "episode_audio_url"
        case episodePubDate = "episode_pub_date"
        case id
        case title
        case description
        case audioUrl = "audio_url"
        case pubDate = "pub_date"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        podcastId = try container.decode(Int.self, forKey: .podcastId)
        podcastTitle = try container.decodeIfPresent(String.self, forKey: .podcastTitle) ?? ""
        podcastImage = try container.decodeIfPresent(String.self, forKey: .podcastImage) ?? ""

        if let legacyEpisodeId = try container.decodeIfPresent(Int.self, forKey: .episodeId) {
            episodeId = legacyEpisodeId
            episodeTitle = try container.decodeIfPresent(String.self, forKey: .episodeTitle) ?? ""
            episodeDescription = try container.decodeIfPresent(String.self, forKey: .episodeDescription) ?? ""
            episodeAudioUrl = try container.decodeIfPresent(String.self, forKey: .episodeAudioUrl) ?? ""
            episodePubDate = try container.decodeIfPresent(String.self, forKey: .episodePubDate) ?? ""
            return
        }

        episodeId = try container.decode(Int.self, forKey: .id)
        episodeTitle = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        episodeDescription = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        episodeAudioUrl = try container.decodeIfPresent(String.self, forKey: .audioUrl) ?? ""
        episodePubDate = try container.decodeIfPresent(String.self, forKey: .pubDate) ?? ""
    }
}

struct Subscription: Decodable, Identifiable {
    let id: Int
    let userId: Int
    let podcastId: Int
    let podcast: Podcast?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, podcast
        case userId = "user_id"
        case podcastId = "podcast_id"
        case createdAt = "created_at"
    }
}

struct SubscriptionActionData: Decodable {
    let message: String?
}

struct PlayProgress: Decodable {
    let id: Int
    let userId: Int
    let episodeId: Int
    let position: Int
    let completed: Bool
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, position, completed
        case userId = "user_id"
        case episodeId = "episode_id"
        case updatedAt = "updated_at"
    }
}
