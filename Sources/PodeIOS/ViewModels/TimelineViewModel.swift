import Foundation
import SwiftUI

@MainActor
class TimelineViewModel: ObservableObject {
    @Published var timeline: [TimelineItem] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var page = 1
    @Published var hasMore = true

    func fetchTimeline(reset: Bool = false) async {
        if reset {
            page = 1
            hasMore = true
        }

        guard !isLoading && hasMore else { return }

        DispatchQueue.main.async { self.isLoading = true }

        do {
            let (items, pagination) = try await PodcastService.shared.getTimeline(page: page)
            DispatchQueue.main.async {
                if reset {
                    self.timeline = items
                } else {
                    self.timeline.append(contentsOf: items)
                }
                self.page += 1
                if let pag = pagination {
                    self.hasMore = pag.page < pag.totalPages
                } else {
                    self.hasMore = false
                }
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
