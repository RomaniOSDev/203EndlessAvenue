import SwiftUI

struct TopicProgressView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = TopicProgressViewModel()
    @State private var selectedTag: String?

    private var topics: [Topic] { store.filteredTopics(by: selectedTag) }

    var body: some View {
        ZStack {
            PatternBackground()
            ScrollView {
                VStack(spacing: 0) {
                    ScreenHeader(
                        title: "Topic Progress",
                        subtitle: "\(store.bookmarkedCardIDs.count) bookmarked items"
                    )

                    TagFilterBar(tags: store.allTags, selectedTag: $selectedTag)

                    if topics.isEmpty {
                        EmptyStateView(message: "Explore and select topics") {
                            BookMagnifyingIllustration()
                        }
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(topics) { topic in
                                VStack(spacing: 10) {
                                    TopicProgressCell(
                                        topic: topic,
                                        percentage: store.learnedPercentage[topic.id] ?? topic.progressPercentage,
                                        weeklyStats: weeklyStats(for: topic),
                                        isExpanded: viewModel.expandedTopicIDs.contains(topic.id),
                                        isPulsing: viewModel.pulsingTopicID == topic.id,
                                        onToggle: { viewModel.toggleExpanded(topic.id) }
                                    )

                                    if viewModel.expandedTopicIDs.contains(topic.id) {
                                        ForEach(topic.cards) { card in
                                            ProgressCardCell(
                                                card: card,
                                                isBookmarked: store.isBookmarked(card.id)
                                            )
                                            .contextMenu {
                                                Button("Bookmark") {
                                                    viewModel.bookmarkCard(card.id, topicID: topic.id, store: store)
                                                }
                                                Button("Delete", role: .destructive) {
                                                    viewModel.deleteCard(card.id, topicID: topic.id, store: store)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    PrimaryButton(title: "View Bookmarked Items", icon: "bookmark.fill") {
                        viewModel.showBookmarkedSheet = true
                    }
                    .padding(16)
                }
            }
            .appScrollStyle()

            SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheckmark)
        }
        .appScreenStyle()
        .sheet(isPresented: $viewModel.showBookmarkedSheet) {
            BookmarkedItemsView().environmentObject(store)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func weeklyStats(for topic: Topic) -> WeeklyStats {
        store.weeklyStats[topic.id] ?? WeeklyStats()
    }
}

struct BookmarkedItemsView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                PatternBackground()
                ScrollView {
                    let items = store.bookmarkedCards()
                    if items.isEmpty {
                        EmptyStateView(systemImage: "bookmark", message: "No bookmarked items yet")
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(items, id: \.card.id) { item in
                                BookmarkCell(
                                    topicTitle: item.topic.title,
                                    question: item.card.question,
                                    answer: item.card.answer
                                )
                            }
                        }
                        .padding(16)
                    }
                }
                .appScrollStyle()
            }
            .appScreenStyle()
            .navigationTitle("Bookmarked Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        HapticManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }
}
