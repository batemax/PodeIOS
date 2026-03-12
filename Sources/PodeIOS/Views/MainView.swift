import SwiftUI

struct MainView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0

    var body: some View {
        if authViewModel.user == nil {
            LoginView(viewModel: authViewModel)
        } else {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    TimelineView()
                        .tabItem {
                            Label("时间线", systemImage: "house")
                        }
                        .tag(0)

                    SearchView()
                        .tabItem {
                            Label("搜索", systemImage: "magnifyingglass")
                        }
                        .tag(1)

                    SubscriptionView()
                        .tabItem {
                            Label("我的订阅", systemImage: "heart")
                        }
                        .tag(2)

                    SettingsView()
                        .tabItem {
                            Label("设置", systemImage: "gear")
                        }
                        .tag(3)
                }

                PlayerView()
            }
        }
    }
}

struct SearchView: View {
    private enum Field {
        case keyword
        case rss
    }

    @State private var keyword = ""
    @State private var podcasts: [Podcast] = []
    @State private var rssUrl = ""
    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("搜索播客", text: $keyword)
                        .accessibilityIdentifier("search_keyword_field")
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focusedField, equals: .keyword)
                        .submitLabel(.search)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit {
                            focusedField = nil
                            performSearch()
                        }
                    Button("搜索") {
                        focusedField = nil
                        performSearch()
                    }
                    .accessibilityIdentifier("search_submit_button")
                }
                .padding()

                HStack {
                    TextField("RSS URL", text: $rssUrl)
                        .accessibilityIdentifier("add_rss_field")
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focusedField, equals: .rss)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("添加") {
                        focusedField = nil
                        Task { try await PodcastService.shared.addPodcast(rssUrl: rssUrl) }
                    }
                    .accessibilityIdentifier("add_rss_button")
                }
                .padding()

                List(podcasts) { podcast in
                    NavigationLink(destination: PodcastDetailView(podcast: podcast)) {
                        HStack {
                            AsyncImage(url: URL(string: podcast.imageUrl)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(4)

                            VStack(alignment: .leading) {
                                Text(podcast.title)
                                    .accessibilityIdentifier("search_podcast_title")
                                    .font(.headline)
                                Text(podcast.author)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Button("订阅") {
                                Task { try await PodcastService.shared.subscribe(podcastId: podcast.id) }
                            }
                            .accessibilityIdentifier("subscribe_button")
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .accessibilityIdentifier("search_results_list")
            }
            .navigationTitle("搜索与添加")
        }
    }

    private func performSearch() {
        let query = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            podcasts = []
            return
        }

        Task {
            do {
                let result = try await PodcastService.shared.searchPodcasts(keyword: query)
                await MainActor.run {
                    podcasts = result
                }
            } catch {
                print("Search podcasts failed: \(error)")
                await MainActor.run {
                    podcasts = []
                }
            }
        }
    }
}

struct SubscriptionView: View {
    @State private var subscriptions: [Subscription] = []

    var body: some View {
        NavigationView {
            List(subscriptions) { sub in
                if let podcast = sub.podcast {
                    NavigationLink(destination: PodcastDetailView(podcast: podcast)) {
                        HStack {
                            AsyncImage(url: URL(string: podcast.imageUrl)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(4)

                            VStack(alignment: .leading) {
                                Text(podcast.title)
                                    .accessibilityIdentifier("subscription_podcast_title")
                                    .font(.headline)
                                Text(podcast.description)
                                    .font(.caption)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("我的订阅")
            .onAppear {
                Task { subscriptions = try await PodcastService.shared.getSubscriptions() }
            }
        }
    }
}
