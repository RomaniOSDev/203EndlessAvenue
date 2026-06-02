import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var unlockedCount: Int {
        AchievementDefinition.all.filter { store.isAchievementUnlocked($0.id) }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PatternBackground()
                ScrollView {
                    VStack(spacing: 16) {
                    ScreenHeader(
                        title: "Achievements",
                        subtitle: "\(unlockedCount)/\(AchievementDefinition.all.count) unlocked"
                    )

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatTile(title: "Cards", value: "\(store.cardsReviewed)", icon: "rectangle.stack.fill")
                        StatTile(title: "Quizzes", value: "\(store.quizzesCompleted)", icon: "brain.head.profile")
                        StatTile(title: "Streak", value: "\(store.streakDays)d", icon: "flame.fill")
                        StatTile(title: "Minutes", value: "\(store.totalMinutesUsed)", icon: "clock.fill")
                    }
                    .padding(.horizontal, 16)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(AchievementDefinition.all) { achievement in
                            AchievementCell(
                                achievement: achievement,
                                isUnlocked: store.isAchievementUnlocked(achievement.id),
                                unlockedDate: store.achievementsUnlocked[achievement.id]
                            )
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
}
