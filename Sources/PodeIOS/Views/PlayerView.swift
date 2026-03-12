import SwiftUI

struct PlayerView: View {
    @ObservedObject var player = AudioPlayerService.shared
    @ObservedObject var downloadManager = DownloadService.shared

    var body: some View {
        if let episode = player.currentEpisode {
            VStack {
                HStack {
                    AsyncImage(url: URL(string: episode.imageUrl)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(4)

                    VStack(alignment: .leading) {
                        Text(episode.title)
                            .font(.subheadline)
                            .lineLimit(1)
                        Text(episode.pubDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: {
                        if player.isPlaying {
                            player.pause()
                        } else {
                            player.resume()
                        }
                    }) {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                    }
                    .padding(.trailing, 8)

                    Button(action: {
                        downloadManager.download(episode: episode)
                    }) {
                        Image(systemName: downloadManager.isDownloaded(episode: episode) ? "checkmark.circle.fill" : "icloud.and.arrow.down")
                            .font(.title2)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(radius: 2)

                Slider(value: Binding(get: {
                    player.currentTime
                }, set: { newValue in
                    player.seek(to: newValue)
                }), in: 0...(player.duration > 0 ? player.duration : 1))
                .padding(.horizontal)
                .accentColor(.blue)
            }
        } else {
            EmptyView()
        }
    }
}
