import SwiftUI

struct WeeklyGoalsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var cardsTargetText = ""
    @State private var quizzesTargetText = ""

    var body: some View {
        ZStack {
            PatternBackground()
            ScrollView {
                VStack(spacing: 16) {
                ScreenHeader(title: "Weekly Goals", subtitle: "Stay on track this week")

                AppCard(accentBorder: store.weeklyGoals.cardsFraction >= 1 || store.weeklyGoals.quizzesFraction >= 1) {
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "This Week")

                        GoalBar(
                            title: "Cards Reviewed",
                            progress: store.weeklyGoals.cardsProgress,
                            target: store.weeklyGoals.cardsTarget,
                            fraction: store.weeklyGoals.cardsFraction,
                            icon: "rectangle.stack.fill"
                        )

                        GoalBar(
                            title: "Quizzes Completed",
                            progress: store.weeklyGoals.quizzesProgress,
                            target: store.weeklyGoals.quizzesTarget,
                            fraction: store.weeklyGoals.quizzesFraction,
                            icon: "checkmark.circle.fill"
                        )
                    }
                }
                .padding(.horizontal, 16)

                AppCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Set Targets")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))

                        HStack {
                            IconBadge(systemName: "rectangle.stack", size: 36, filled: false)
                            TextField("Cards target", text: $cardsTargetText)
                                .keyboardType(.numberPad)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        .padding(12)
                        .background(Color("AppBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        HStack {
                            IconBadge(systemName: "brain", size: 36, filled: false)
                            TextField("Quizzes target", text: $quizzesTargetText)
                                .keyboardType(.numberPad)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        .padding(12)
                        .background(Color("AppBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        PrimaryButton(title: "Save Targets", icon: "target") {
                            let cards = Int(cardsTargetText) ?? store.weeklyGoals.cardsTarget
                            let quizzes = Int(quizzesTargetText) ?? store.weeklyGoals.quizzesTarget
                            store.updateWeeklyGoalTargets(cards: cards, quizzes: quizzes)
                            HapticManager.mediumImpact()
                            SoundManager.playSuccess()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                }
            }
            .appScrollStyle()
        }
        .appScreenStyle()
        .onAppear {
            cardsTargetText = "\(store.weeklyGoals.cardsTarget)"
            quizzesTargetText = "\(store.weeklyGoals.quizzesTarget)"
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GoalBar: View {
    let title: String
    let progress: Int
    let target: Int
    let fraction: Double
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color("AppAccent"))
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                Text("\(progress)/\(target)")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppDesign.Gradients.surface)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppDesign.Gradients.primaryHorizontal)
                        .frame(width: geo.size.width * fraction)
                }
            }
            .frame(height: 10)
        }
    }
}
