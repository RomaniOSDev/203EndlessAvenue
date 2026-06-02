import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var selectedTab: MainTab

    private var dueCount: Int { store.cardsDueToday().count }
    private var unlockedAchievements: Int {
        AchievementDefinition.all.filter { store.isAchievementUnlocked($0.id) }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PatternBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        heroBanner
                        quickStartSection
                        todaySnapshotSection
                        weeklyGoalsWidget
                        continueLearningWidget
                        achievementsWidget
                        exploreShortcuts
                    }
                    .padding(.bottom, 24)
                }
                .appScrollStyle()
            }
            .appScreenStyle()
            .navigationBarHidden(true)
        }
    }

    // MARK: - Hero

    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            LinearGradient(
                colors: [.clear, Color("AppBackground").opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.title2.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(heroSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    streakBadge
                }

                if dueCount > 0 {
                    NavigationLink {
                        ReviewDueTodayView()
                            .environmentObject(store)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                            Text("Review \(dueCount) card\(dueCount == 1 ? "" : "s") now")
                                .font(.subheadline.bold())
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.caption.bold())
                        }
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .appPrimaryButtonChrome(cornerRadius: 12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .appCardChrome(cornerRadius: 20, accentBorder: dueCount > 0, elevation: .elevated)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var streakBadge: some View {
        VStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundStyle(Color("AppAccent"))
            Text("\(store.streakDays)d")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
            Text("Streak")
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            AppCardBackground(cornerRadius: 12)
        }
        .appShadow(.soft)
    }

    // MARK: - Quick Start

    private var quickStartSection: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Quick Start")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                HomeActionWidget(
                    imageName: "HomeWidgetReview",
                    title: "Review Due",
                    subtitle: dueCount == 0 ? "All caught up" : "\(dueCount) waiting",
                    badge: dueCount,
                    accent: dueCount > 0
                ) {
                    ReviewDueTodayView()
                        .environmentObject(store)
                }

                HomeActionWidget(
                    imageName: "HomeWidgetReview",
                    title: "Quick Review",
                    subtitle: "5–10 min session",
                    badge: min(10, store.quickReviewCards().count),
                    accent: false
                ) {
                    QuickReviewView()
                        .environmentObject(store)
                }

                HomeActionWidget(
                    imageName: "HomeWidgetQuiz",
                    title: "Concept Quiz",
                    subtitle: "\(store.quizQuestions.count) questions",
                    badge: store.quizQuestions.count,
                    accent: false
                ) {
                    ConceptQuizView()
                        .environmentObject(store)
                }

                HomeActionWidget(
                    imageName: "HomeWidgetGoals",
                    title: "Weekly Goals",
                    subtitle: goalsSubtitle,
                    badge: nil,
                    accent: store.weeklyGoals.cardsFraction >= 1
                ) {
                    WeeklyGoalsView()
                        .environmentObject(store)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Stats

    private var todaySnapshotSection: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Today's Snapshot")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatTile(title: "Cards Learned", value: "\(store.cardsReviewed)", icon: "rectangle.stack.fill")
                StatTile(title: "Quiz Score", value: store.completedQuizzes.isEmpty ? "—" : "\(store.averageQuizScore)%", icon: "percent")
                StatTile(title: "Topics", value: "\(store.topics.count)", icon: "books.vertical.fill")
                StatTile(title: "Minutes", value: "\(store.totalMinutesUsed)", icon: "clock.fill")
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Weekly Goals

    private var weeklyGoalsWidget: some View {
        NavigationLink {
            WeeklyGoalsView()
                .environmentObject(store)
        } label: {
            AppCard(accentBorder: store.weeklyGoals.cardsFraction >= 1) {
                HStack(spacing: 14) {
                    Image("HomeWidgetGoals")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Weekly Progress")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))

                        HomeMiniProgressBar(
                            title: "Cards",
                            progress: store.weeklyGoals.cardsProgress,
                            target: store.weeklyGoals.cardsTarget,
                            fraction: store.weeklyGoals.cardsFraction
                        )

                        HomeMiniProgressBar(
                            title: "Quizzes",
                            progress: store.weeklyGoals.quizzesProgress,
                            target: store.weeklyGoals.quizzesTarget,
                            fraction: store.weeklyGoals.quizzesFraction
                        )
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    // MARK: - Continue Learning

    @ViewBuilder
    private var continueLearningWidget: some View {
        if let topic = continueTopic {
            VStack(spacing: 12) {
                SectionHeader(title: "Continue Learning")

                NavigationLink {
                    TopicProgressView()
                        .environmentObject(store)
                } label: {
                    AppCard(accentBorder: true) {
                        HStack(spacing: 14) {
                            ProgressRingView(
                                percentage: store.learnedPercentage[topic.id] ?? topic.progressPercentage,
                                lineWidth: 6,
                                size: 56
                            )

                            VStack(alignment: .leading, spacing: 6) {
                                Text(topic.title)
                                    .font(.headline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .lineLimit(2)

                                Text(continueTopicSubtitle(for: topic))
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))

                                if !topic.tags.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 6) {
                                            ForEach(topic.tags.prefix(3), id: \.self) { tag in
                                                Text(tag)
                                                    .font(.caption2)
                                                    .foregroundStyle(Color("AppAccent"))
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color("AppAccent").opacity(0.15))
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Achievements

    private var achievementsWidget: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "Achievements",
                trailing: "\(unlockedAchievements)/\(AchievementDefinition.all.count)"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AchievementDefinition.all.prefix(6)) { achievement in
                        HomeAchievementChip(
                            achievement: achievement,
                            isUnlocked: store.isAchievementUnlocked(achievement.id)
                        )
                    }

                    Button {
                        HapticManager.lightTap()
                        selectedTab = .achievements
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "ellipsis")
                                .font(.title3)
                                .foregroundStyle(Color("AppAccent"))
                                .frame(width: 48, height: 48)
                                .background(Color("AppSurface"))
                                .clipShape(Circle())
                            Text("See All")
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        .frame(width: 80)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Shortcuts

    private var exploreShortcuts: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Explore More")

            HStack(spacing: 10) {
                HomeShortcutButton(title: "Topics", icon: "book.fill") {
                    selectedTab = .explorer
                }
                HomeShortcutLink(title: "Insights", icon: "chart.xyaxis.line") {
                    StudyInsightsView().environmentObject(store)
                }
                HomeShortcutLink(title: "Map", icon: "point.3.connected.trianglepath.dotted") {
                    ConceptMapView().environmentObject(store)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Helpers

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    private var heroSubtitle: String {
        if dueCount > 0 {
            return "You have cards ready to review"
        }
        if store.topics.isEmpty {
            return "Add topics to start your learning journey"
        }
        return "Keep your streak going — you're doing great"
    }

    private var goalsSubtitle: String {
        let remaining = max(0, store.weeklyGoals.cardsTarget - store.weeklyGoals.cardsProgress)
        return remaining == 0 ? "Cards goal reached!" : "\(remaining) cards to go"
    }

    private var continueTopic: Topic? {
        if let lastID = store.lastViewedTopicID,
           let topic = store.topics.first(where: { $0.id == lastID }) {
            return topic
        }
        return store.weakestTopic ?? store.topics.first
    }

    private func continueTopicSubtitle(for topic: Topic) -> String {
        let pct = Int(store.learnedPercentage[topic.id] ?? topic.progressPercentage)
        let due = store.dueCount(for: topic.id)
        if due > 0 { return "\(pct)% learned · \(due) due today" }
        return "\(pct)% learned · \(topic.cards.count) cards"
    }
}

// MARK: - Widget Components

private struct HomeActionWidget<Destination: View>: View {
    let imageName: String
    let title: String
    let subtitle: String
    var badge: Int?
    var accent: Bool
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 88)
                        .clipped()

                    if let badge, badge > 0 {
                        Text("\(badge)")
                            .font(.caption2.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color("AppAccent"))
                            .clipShape(Capsule())
                            .padding(8)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppDesign.Gradients.surface)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .appCardChrome(accentBorder: accent, elevation: accent ? .elevated : .soft)
        }
        .buttonStyle(.plain)
    }
}

private struct HomeMiniProgressBar: View {
    let title: String
    let progress: Int
    let target: Int
    let fraction: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Spacer()
                Text("\(progress)/\(target)")
                    .font(.caption2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppDesign.Gradients.surface)
                    Capsule()
                        .fill(AppDesign.Gradients.primaryHorizontal)
                        .frame(width: geo.size.width * min(1, fraction))
                }
            }
            .frame(height: 6)
        }
    }
}

private struct HomeAchievementChip: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked
                            ? LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color("AppSurface"), Color("AppSurface")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: 48, height: 48)
                Image(systemName: achievement.systemImage)
                    .font(.body)
                    .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary").opacity(0.5))
            }
            Text(achievement.title)
                .font(.caption2)
                .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
        .opacity(isUnlocked ? 1 : 0.65)
    }
}

private struct HomeShortcutLink<Destination: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            VStack(spacing: 8) {
                IconBadge(systemName: icon, size: 44, filled: false)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .appCardChrome(cornerRadius: 14, elevation: .soft)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded { HapticManager.lightTap() })
    }
}

private struct HomeShortcutButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.lightTap()
            action()
        } label: {
            VStack(spacing: 8) {
                IconBadge(systemName: icon, size: 44, filled: false)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .appCardChrome(cornerRadius: 14, elevation: .soft)
        }
        .buttonStyle(.plain)
    }
}
