import SwiftUI
import Combine

struct QuickReviewView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase

    @State private var sessionCards: [CardReference] = []
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var sessionActive = false
    @State private var elapsedSeconds = 0
    @State private var reviewedCount = 0
    @State private var timerActive = false
    @State private var showSuccess = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            PatternBackground()
            ScrollView {
                VStack(spacing: 16) {
                ScreenHeader(title: "Quick Review", subtitle: sessionSubtitle)

                if sessionActive {
                    AppCard(accentBorder: true) {
                        HStack {
                            Label(formatTime(elapsedSeconds), systemImage: "clock.fill")
                                .foregroundStyle(Color("AppAccent"))
                            Spacer()
                            CountBadge(count: max(0, sessionCards.count - currentIndex))
                            Text("left")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                    .padding(.horizontal, 16)

                    if currentIndex < sessionCards.count {
                        ReviewCardView(
                            reference: sessionCards[currentIndex],
                            isFlipped: isFlipped,
                            showSelfCheck: isFlipped,
                            onFlip: {
                                HapticManager.lightTap()
                                isFlipped.toggle()
                            },
                            onGotIt: { advance(gotIt: true) },
                            onNeedReview: { advance(gotIt: false) }
                        )
                        .padding(.horizontal, 16)
                    } else {
                        sessionCompleteView
                    }
                } else {
                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Short focused session")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("Review up to 10 cards that are due today or marked as in progress.")
                                .font(.subheadline)
                                .foregroundStyle(Color("AppTextSecondary"))
                            HStack {
                                StatTile(title: "Due", value: "\(store.cardsDueToday().count)", icon: "calendar")
                                StatTile(title: "Ready", value: "\(store.quickReviewCards().count)", icon: "bolt.fill")
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    PrimaryButton(title: "Start Session", icon: "play.fill") {
                        startSession()
                    }
                    .padding(.horizontal, 16)
                }
                }
                .padding(.bottom, 24)
            }
            .appScrollStyle()

            SuccessCheckmarkOverlay(isVisible: $showSuccess)
        }
        .appScreenStyle()
        .onReceive(timer) { _ in
            guard timerActive, scenePhase == .active else { return }
            elapsedSeconds += 1
        }
        .onChange(of: scenePhase) { phase in
            timerActive = sessionActive && phase == .active
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var sessionSubtitle: String {
        sessionActive ? "Card \(min(currentIndex + 1, sessionCards.count)) of \(sessionCards.count)" : "5–10 card session"
    }

    private var sessionCompleteView: some View {
        VStack(spacing: 16) {
            EmptyStateView(systemImage: "checkmark.seal.fill", message: "Session complete! Reviewed \(reviewedCount) cards.")
            PrimaryButton(title: "New Session", icon: "arrow.clockwise") {
                finishSession()
                startSession()
            }
            .padding(.horizontal, 16)
        }
    }

    private func startSession() {
        sessionCards = store.quickReviewCards(limit: 10)
        currentIndex = 0
        isFlipped = false
        elapsedSeconds = 0
        reviewedCount = 0
        sessionActive = true
        timerActive = true
        HapticManager.mediumImpact()
        SoundManager.playTick()
    }

    private func advance(gotIt: Bool) {
        guard currentIndex < sessionCards.count else { return }
        let ref = sessionCards[currentIndex]
        store.selfCheckCard(ref.card.id, in: ref.topic.id, gotIt: gotIt)
        reviewedCount += 1
        HapticManager.mediumImpact()
        SoundManager.playMarkKnown()
        isFlipped = false
        currentIndex += 1
        showSuccess = true
        if currentIndex >= sessionCards.count { finishSession() }
    }

    private func finishSession() {
        timerActive = false
        let minutes = max(1, elapsedSeconds / 60)
        if reviewedCount > 0 {
            store.completeQuickReviewSession(minutes: minutes, cardsCount: reviewedCount)
            HapticManager.success()
            SoundManager.playSuccess()
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
