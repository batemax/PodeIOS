import Foundation
import AVFoundation

@MainActor
class AudioPlayerService: ObservableObject {
    static let shared = AudioPlayerService()
    private var player: AVPlayer?
    @Published var isPlaying = false
    @Published var currentEpisode: Episode?
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0

    private var timeObserver: Any?

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category.")
        }
    }

    func play(episode: Episode) {
        if currentEpisode?.id == episode.id {
            resume()
            return
        }

        currentEpisode = episode
        guard let url = URL(string: episode.audioUrl) else { return }

        let localUrl = DownloadService.shared.getLocalUrl(for: episode)
        let playUrl = FileManager.default.fileExists(atPath: localUrl.path) ? localUrl : url

        let playerItem = AVPlayerItem(url: playUrl)
        player = AVPlayer(playerItem: playerItem)

        removeTimeObserver()
        addTimeObserver()

        player?.play()
        isPlaying = true

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    @objc private func playerDidFinishPlaying() {
        Task { @MainActor in
            isPlaying = false
            if let ep = currentEpisode {
                try? await PodcastService.shared.updateProgress(episodeId: ep.id, position: Int(duration), completed: true)
            }
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateProgressOnServer()
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: time)
    }

    private func addTimeObserver() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            Task { @MainActor in
                self?.currentTime = time.seconds
                self?.duration = self?.player?.currentItem?.duration.seconds ?? 0
            }
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    private func updateProgressOnServer() {
        guard let ep = currentEpisode else { return }
        Task {
            try? await PodcastService.shared.updateProgress(episodeId: ep.id, position: Int(currentTime), completed: false)
        }
    }
}
