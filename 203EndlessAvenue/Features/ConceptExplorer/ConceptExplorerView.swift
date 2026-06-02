import SwiftUI

struct ConceptExplorerView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = ConceptExplorerViewModel()
    @State private var selectedTag: String?
    @State private var searchText = ""
    @State private var editingTopic: Topic?

    private var filteredTopics: [Topic] {
        let tagged = store.filteredTopics(by: selectedTag)
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return tagged }
        let query = searchText.lowercased()
        return tagged.filter { topic in
            topic.title.lowercased().contains(query) ||
            topic.tags.contains { $0.lowercased().contains(query) } ||
            topic.cards.contains {
                $0.question.lowercased().contains(query) || $0.answer.lowercased().contains(query)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PatternBackground()
                ScrollView {
                    VStack(spacing: 0) {
                        ScreenHeader(
                            title: "Concept Explorer",
                            subtitle: "\(store.totalCards) cards · \(store.topics.count) topics"
                        )

                        SearchField(text: $searchText, placeholder: "Search topics and cards")
                        TagFilterBar(tags: store.allTags, selectedTag: $selectedTag)

                        if filteredTopics.isEmpty {
                            EmptyStateView(message: "Explore your concepts here!") {
                                BookMagnifyingIllustration()
                            }
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredTopics) { topic in
                                    VStack(spacing: 10) {
                                        TopicCell(
                                            topic: topic,
                                            isExpanded: viewModel.expandedTopicIDs.contains(topic.id),
                                            dueCount: store.dueCount(for: topic.id),
                                            onToggle: { viewModel.toggleTopic(topic.id, store: store) },
                                            onEdit: { editingTopic = topic }
                                        )

                                        if viewModel.expandedTopicIDs.contains(topic.id) {
                                            ForEach(topic.cards) { card in
                                                FlashcardCell(
                                                    card: card,
                                                    isFlipped: viewModel.flippedCardIDs.contains(card.id),
                                                    isPulsing: viewModel.pulsingCardID == card.id,
                                                    dueLabel: store.nextReviewLabel(for: card.id),
                                                    onFlip: { viewModel.toggleFlip(card.id) },
                                                    onMarkKnown: {
                                                        viewModel.markKnown(cardID: card.id, topicID: topic.id, store: store)
                                                    },
                                                    onMarkInProgress: {
                                                        viewModel.markInProgress(cardID: card.id, topicID: topic.id, store: store)
                                                    },
                                                    onGotIt: {
                                                        store.selfCheckCard(card.id, in: topic.id, gotIt: true)
                                                        viewModel.pulsingCardID = card.id
                                                        viewModel.showSuccessCheckmark = true
                                                        HapticManager.mediumImpact()
                                                        SoundManager.playMarkKnown()
                                                    },
                                                    onNeedReview: {
                                                        store.selfCheckCard(card.id, in: topic.id, gotIt: false)
                                                        HapticManager.mediumImpact()
                                                        SoundManager.playTick()
                                                    }
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        PrimaryButton(title: "Add New Topic", icon: "plus.circle.fill") {
                            viewModel.showAddTopicSheet = true
                        }
                        .padding(16)
                    }
                }
                .appScrollStyle()

                SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheckmark)
            }
            .appScreenStyle()
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showAddTopicSheet) {
                AddTopicSheet(isPresented: $viewModel.showAddTopicSheet).environmentObject(store)
            }
            .sheet(item: $editingTopic) { topic in
                EditTopicSheet(topic: topic, isPresented: Binding(
                    get: { editingTopic != nil },
                    set: { if !$0 { editingTopic = nil } }
                ))
                .environmentObject(store)
            }
        }
    }
}
