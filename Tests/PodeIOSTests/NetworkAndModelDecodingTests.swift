import XCTest
@testable import PodeIOS

final class NetworkAndModelDecodingTests: XCTestCase {
    func testTimelineDecodingWithCurrentServerShape() throws {
        let json = """
        {
          "code": 0,
          "message": "success",
          "data": [
            {
              "id": 1614,
              "podcast_id": 1,
              "title": "Episode title",
              "description": "Desc",
              "audio_url": "https://example.com/audio.mp3",
              "pub_date": "2026-03-12T07:15:00Z",
              "podcast_title": "Podcast name",
              "podcast_image": "https://example.com/podcast.jpg"
            }
          ],
          "pagination": {
            "page": 1,
            "page_size": 20,
            "total": 100,
            "total_pages": 5
          }
        }
        """

        let response: ApiResponse<[TimelineItem]> = try decode(json)
        let item = try XCTUnwrap(response.data?.first)

        XCTAssertEqual(item.episodeId, 1614)
        XCTAssertEqual(item.episodeTitle, "Episode title")
        XCTAssertEqual(item.episodeAudioUrl, "https://example.com/audio.mp3")
        XCTAssertEqual(item.episodePubDate, "2026-03-12T07:15:00Z")
        XCTAssertEqual(item.podcastTitle, "Podcast name")
        XCTAssertEqual(response.pagination?.totalPages, 5)
    }

    func testPodcastDecodingSupportsLastRefreshedAtFallback() throws {
        let json = """
        {
          "code": 0,
          "message": "success",
          "data": [
            {
              "id": 1,
              "title": "The Bible in a Year",
              "description": "Desc",
              "rss_url": "https://example.com/rss",
              "image_url": "https://example.com/image.jpg",
              "author": "Ascension",
              "link": "https://example.com",
              "category": "Religion",
              "last_refreshed_at": "2026-03-12T09:04:30.519919245Z",
              "created_at": "2026-03-09T10:20:00.031043995Z"
            }
          ]
        }
        """

        let response: ApiResponse<[Podcast]> = try decode(json)
        let podcast = try XCTUnwrap(response.data?.first)

        XCTAssertEqual(podcast.id, 1)
        XCTAssertEqual(podcast.lastBuildDate, "2026-03-12T09:04:30.519919245Z")
        XCTAssertEqual(podcast.title, "The Bible in a Year")
    }

    func testEpisodeDecodingSupportsMimeFileSizeAndDuration() throws {
        let json = """
        {
          "code": 0,
          "message": "success",
          "data": [
            {
              "id": 1614,
              "podcast_id": 1,
              "guid": "g-1",
              "title": "Episode",
              "description": "Desc",
              "audio_url": "https://example.com/audio.mp3",
              "mime_type": "audio/mpeg",
              "file_size": 21886827,
              "duration": 1365,
              "pub_date": "2026-03-12T07:15:00Z",
              "image_url": "https://example.com/p.jpg"
            }
          ]
        }
        """

        let response: ApiResponse<[Episode]> = try decode(json)
        let episode = try XCTUnwrap(response.data?.first)

        XCTAssertEqual(episode.audioType, "audio/mpeg")
        XCTAssertEqual(episode.audioSize, 21886827)
        XCTAssertEqual(episode.audioDuration, 1365)
    }

    func testDateDecodingSupportsFractionalSeconds() throws {
        let json = """
        {
          "code": 0,
          "message": "success",
          "data": {
            "id": 2,
            "user_id": 9,
            "episode_id": 1,
            "position": 123,
            "completed": false,
            "updated_at": "2026-03-12T09:22:09.111902754Z"
          }
        }
        """

        let response: ApiResponse<PlayProgress> = try decode(json)
        let progress = try XCTUnwrap(response.data)
        XCTAssertNotNil(progress.updatedAt)
        XCTAssertEqual(progress.position, 123)
        XCTAssertFalse(progress.completed)
    }

    func testSubscriptionActionPayloadDecoding() throws {
        let json = """
        {
          "code": 0,
          "message": "success",
          "data": {
            "message": "unsubscribed successfully"
          }
        }
        """

        let response: ApiResponse<SubscriptionActionData> = try decode(json)
        XCTAssertEqual(response.data?.message, "unsubscribed successfully")
    }

    private func decode<T: Decodable>(_ raw: String) throws -> T {
        let data = Data(raw.utf8)
        return try NetworkService.makeDecoder().decode(T.self, from: data)
    }
}
