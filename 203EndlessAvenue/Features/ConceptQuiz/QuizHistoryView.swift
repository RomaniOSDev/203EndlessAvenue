import SwiftUI

struct QuizHistoryView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var filterTopicID: String?

    private var filteredResults: [QuizResult] {
        guard let filterTopicID else { return store.completedQuizzes }
        return store.completedQuizzes.filter { $0.topicID == filterTopicID }
    }

    var body: some View {
        ZStack {
            PatternBackground()
            ScrollView {
                VStack(spacing: 0) {
                ScreenHeader(
                    title: "Quiz History",
                    subtitle: store.completedQuizzes.isEmpty ? "No results yet" : "Avg \(store.averageQuizScore)%"
                )

                if !store.topics.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", isSelected: filterTopicID == nil) {
                                HapticManager.lightTap()
                                filterTopicID = nil
                            }
                            ForEach(store.topics) { topic in
                                FilterChip(title: topic.title, isSelected: filterTopicID == topic.id) {
                                    HapticManager.lightTap()
                                    filterTopicID = topic.id
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 8)
                }

                if filteredResults.isEmpty {
                    EmptyStateView(systemImage: "clock.arrow.circlepath", message: "No quiz results yet")
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredResults) { result in
                            QuizHistoryCell(result: result)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                }
            }
            .appScrollStyle()
        }
        .appScreenStyle()
        .navigationBarTitleDisplayMode(.inline)
    }
}
