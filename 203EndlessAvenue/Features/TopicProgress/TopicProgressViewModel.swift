import SwiftUI
import Combine

final class TopicProgressViewModel: ObservableObject {
    @Published var expandedTopicIDs: Set<String> = []
    @Published var showBookmarkedSheet = false
    @Published var showSuccessCheckmark = false
    @Published var pulsingTopicID: String?

    func toggleExpanded(_ topicID: String) {
        HapticManager.lightTap()
        if expandedTopicIDs.contains(topicID) {
            expandedTopicIDs.remove(topicID)
        } else {
            expandedTopicIDs.insert(topicID)
        }
    }

    func bookmarkCard(_ cardID: String, topicID: String, store: AppDataStore) {
        store.toggleBookmark(cardID: cardID, topicID: topicID)
        HapticManager.mediumImpact()
        SoundManager.playMarkKnown()
        pulsingTopicID = topicID
        showSuccessCheckmark = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.pulsingTopicID = nil
        }
    }

    func deleteCard(_ cardID: String, topicID: String, store: AppDataStore) {
        store.deleteCard(cardID, from: topicID)
        HapticManager.mediumImpact()
        SoundManager.playTick()
    }
}
