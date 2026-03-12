import SwiftUI

struct TimelineView: View {
    @StateObject var viewModel = TimelineViewModel()
    @ObservedObject var player = AudioPlayerService.shared

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.timeline) { item in
                    TimelineRow(item: item)
                        .onTapGesture {
                            playEpisode(item: item)
                        }
                        .onAppear {
                            if item.id == viewModel.timeline.last?.id {
                                Task { await viewModel.fetchTimeline() }
                            }
                        }
                }

                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .navigationTitle("时间线")
            .refreshable {
                await viewModel.fetchTimeline(reset: true)
            }
            .onAppear {
                if viewModel.timeline.isEmpty {
                    Task { await viewModel.fetchTimeline() }
                }
            }
        }
    }

    private func playEpisode(item: TimelineItem) {
        let episode = Episode(
            id: item.episodeId,
            podcastId: item.podcastId,
            guid: "",
            title: item.episodeTitle,
            description: item.episodeDescription,
            audioUrl: item.episodeAudioUrl,
            audioType: "",
            audioSize: 0,
            audioDuration: 0,
            pubDate: item.episodePubDate,
            imageUrl: item.podcastImage,
            createdAt: nil
        )
        player.play(episode: episode)
    }
}

struct TimelineRow: View {
    let item: TimelineItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: item.podcastImage)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.episodeTitle)
                    .font(.headline)
                    .lineLimit(2)
                Text(item.podcastTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(item.episodePubDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
