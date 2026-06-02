import SwiftUI

struct StudyHubView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        NavigationStack {
            ZStack {
                PatternBackground()
                ScrollView {
                    VStack(spacing: 0) {
                    ScreenHeader(
                        title: "Study",
                        subtitle: "\(store.cardsDueToday().count) cards due today"
                    )

                    LazyVStack(spacing: 12) {
                        ForEach(StudyDestination.allCases) { destination in
                            NavigationLink {
                                destinationView(for: destination)
                                    .environmentObject(store)
                            } label: {
                                StudyHubCell(
                                    destination: destination,
                                    badgeCount: badgeCount(for: destination)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    }
                }
                .appScrollStyle()
            }
            .appScreenStyle()
            .navigationBarHidden(true)
        }
    }

    private func badgeCount(for destination: StudyDestination) -> Int {
        switch destination {
        case .reviewDue: return store.cardsDueToday().count
        case .quickReview: return min(10, store.quickReviewCards().count)
        case .quiz: return store.quizQuestions.count
        case .quizHistory: return store.completedQuizzes.count
        case .progress: return store.topics.count
        case .conceptMap: return store.conceptConnections.count
        case .insights: return store.activityForLastDays(7).filter { $0.activity.cardsReviewed > 0 }.count
        case .weeklyGoals: return max(0, store.weeklyGoals.cardsTarget - store.weeklyGoals.cardsProgress)
        }
    }

    @ViewBuilder
    private func destinationView(for destination: StudyDestination) -> some View {
        switch destination {
        case .reviewDue: ReviewDueTodayView()
        case .quickReview: QuickReviewView()
        case .quiz: ConceptQuizView()
        case .quizHistory: QuizHistoryView()
        case .progress: TopicProgressView()
        case .conceptMap: ConceptMapView()
        case .insights: StudyInsightsView()
        case .weeklyGoals: WeeklyGoalsView()
        }
    }
}
