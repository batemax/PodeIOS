import SwiftUI

struct PodcastDetailView: View {
    let podcast: Podcast
    @State private var episodes: [Episode] = []
    @State private var isLoading = false
    @ObservedObject var player = AudioPlayerService.shared

    var body: some View {
        List {
            Section(header: PodcastHeader(podcast: podcast)) {
                if isLoading {
                    ProgressView()
                } else {
                    ForEach(episodes) { episode in
                        VStack(alignment: .leading) {
                            Text(episode.title)
                                .font(.headline)
                            Text(episode.pubDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            player.play(episode: episode)
                        }
                    }
                }
            }
        }
        .navigationTitle(podcast.title)
        .onAppear {
            fetchEpisodes()
        }
    }

    private func fetchEpisodes() {
        isLoading = true
        Task {
            do {
                let response: ApiResponse<Podcast> = try await NetworkService.shared.request(
                    endpoint: "/podcasts/\(podcast.id)"
                )
                if let detail = response.data {
                    DispatchQueue.main.async {
                        self.episodes = detail.episodes ?? []
                        self.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}

struct PodcastHeader: View {
    let podcast: Podcast

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: podcast.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 100, height: 100)
            .cornerRadius(8)

            Text(podcast.author)
                .font(.subheadline)
                .foregroundColor(.blue)

            Text(podcast.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
}
