import SwiftUI

struct EditTopicSheet: View {
    @EnvironmentObject private var store: AppDataStore
    let topic: Topic
    @Binding var isPresented: Bool

    @State private var title = ""
    @State private var topicTagsText = ""
    @State private var cards: [Flashcard] = []
    @State private var editMode: EditMode = .inactive
    @State private var errorMessage: String?
    @State private var shakeTrigger = 0

    var body: some View {
        NavigationStack {
            ZStack {
                PatternBackground()
                List {
                    Section("Topic") {
                        TextField("Title", text: $title)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: shakeTrigger)
                        TextField("Tags (comma separated)", text: $topicTagsText)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .listRowBackground(Color("AppSurface"))

                    Section("Cards") {
                        ForEach($cards) { $card in
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Question", text: $card.question)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                TextField("Answer", text: $card.answer)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                TextField("Tags", text: Binding(
                                    get: { card.tags.joined(separator: ", ") },
                                    set: { card.tags = parseTags($0) }
                                ))
                                .foregroundStyle(Color("AppTextPrimary"))
                            }
                            .padding(.vertical, 4)
                        }
                        .onMove { from, to in cards.move(fromOffsets: from, toOffset: to) }
                        .onDelete { indexSet in cards.remove(atOffsets: indexSet) }
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
                .appScrollStyle()
            }
            .appScreenStyle()
            .environment(\.editMode, $editMode)
            .navigationTitle("Edit Topic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Add Card") {
                        HapticManager.lightTap()
                        cards.append(Flashcard(question: "", answer: ""))
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .onAppear {
                title = topic.title
                topicTagsText = topic.tags.joined(separator: ", ")
                cards = topic.cards
            }
        }
    }

    private func parseTags(_ text: String) -> [String] {
        text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    private func save() {
        let validCards = cards.filter {
            !$0.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        let success = store.updateTopic(topic.id, title: title, tags: parseTags(topicTagsText), cards: validCards)
        if success {
            HapticManager.mediumImpact()
            SoundManager.playSuccess()
            isPresented = false
        } else {
            HapticManager.warning()
            errorMessage = "Enter a valid title and at least one card."
            shakeTrigger += 1
        }
    }
}
