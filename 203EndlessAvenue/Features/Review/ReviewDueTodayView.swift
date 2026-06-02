import SwiftUI

struct ReviewDueTodayView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var flippedIDs: Set<String> = []
    @State private var completedIDs: Set<String> = []
    @State private var showSuccess = false

    private var dueCards: [CardReference] {
        store.cardsDueToday().filter { !completedIDs.contains($0.card.id) }
    }

    var body: some View {
        ZStack {
            PatternBackground()
            ScrollView {
                VStack(spacing: 0) {
                ScreenHeader(
                    title: "Review Due Today",
                    subtitle: "\(dueCards.count) cards remaining"
                )

                if dueCards.isEmpty {
                    EmptyStateView(
                        systemImage: "checkmark.circle.fill",
                        message: completedIDs.isEmpty ? "No cards due today" : "All due cards reviewed!"
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(dueCards) { ref in
                            ReviewCardView(
                                reference: ref,
                                isFlipped: flippedIDs.contains(ref.card.id),
                                showSelfCheck: true,
                                onFlip: {
                                    if flippedIDs.contains(ref.card.id) {
                                        flippedIDs.remove(ref.card.id)
                                    } else {
                                        flippedIDs.insert(ref.card.id)
                                    }
                                },
                                onGotIt: { finish(ref, gotIt: true) },
                                onNeedReview: { finish(ref, gotIt: false) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                }
            }
            .appScrollStyle()

            SuccessCheckmarkOverlay(isVisible: $showSuccess)
        }
        .appScreenStyle()
        .navigationBarTitleDisplayMode(.inline)
    }

    private func finish(_ ref: CardReference, gotIt: Bool) {
        store.selfCheckCard(ref.card.id, in: ref.topic.id, gotIt: gotIt)
        HapticManager.mediumImpact()
        SoundManager.playMarkKnown()
        completedIDs.insert(ref.card.id)
        flippedIDs.remove(ref.card.id)
        showSuccess = true
    }
}
