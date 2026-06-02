import SwiftUI
import Combine

final class ConceptExplorerViewModel: ObservableObject {
    @Published var expandedTopicIDs: Set<String> = []
    @Published var flippedCardIDs: Set<String> = []
    @Published var showAddTopicSheet = false
    @Published var showSuccessCheckmark = false
    @Published var pulsingCardID: String?

    func toggleTopic(_ topicID: String, store: AppDataStore) {
        HapticManager.lightTap()
        if expandedTopicIDs.contains(topicID) {
            expandedTopicIDs.remove(topicID)
        } else {
            expandedTopicIDs.insert(topicID)
            store.toggleTopicExpansion(topicID)
        }
    }

    func toggleFlip(_ cardID: String) {
        HapticManager.lightTap()
        if flippedCardIDs.contains(cardID) {
            flippedCardIDs.remove(cardID)
        } else {
            flippedCardIDs.insert(cardID)
        }
    }

    func markKnown(cardID: String, topicID: String, store: AppDataStore) {
        store.markCard(cardID, in: topicID, status: .known)
        HapticManager.mediumImpact()
        SoundManager.playMarkKnown()
        pulsingCardID = cardID
        showSuccessCheckmark = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.pulsingCardID = nil
        }
    }

    func markInProgress(cardID: String, topicID: String, store: AppDataStore) {
        store.markCard(cardID, in: topicID, status: .inProgress)
        HapticManager.mediumImpact()
        SoundManager.playTick()
    }
}
