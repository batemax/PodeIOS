import Foundation

class DownloadService: NSObject, ObservableObject {
    static let shared = DownloadService()
    @Published var downloads: [Int: Float] = [:]

    private override init() {}

    func download(episode: Episode) {
        guard let url = URL(string: episode.audioUrl) else { return }
        let task = URLSession.shared.downloadTask(with: url) { localUrl, response, error in
            guard let localUrl = localUrl else { return }
            let destination = self.getLocalUrl(for: episode)

            try? FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? FileManager.default.removeItem(at: destination)
            try? FileManager.default.moveItem(at: localUrl, to: destination)

            DispatchQueue.main.async {
                self.downloads[episode.id] = 1.0
            }
        }
        task.resume()
    }

    func getLocalUrl(for episode: Episode) -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("downloads/\(episode.id).mp3")
    }

    func isDownloaded(episode: Episode) -> Bool {
        return FileManager.default.fileExists(atPath: getLocalUrl(for: episode).path)
    }
}
