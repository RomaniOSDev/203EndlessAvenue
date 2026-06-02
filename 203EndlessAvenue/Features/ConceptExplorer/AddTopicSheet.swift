import SwiftUI

struct AddTopicSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var topicTagsText = ""
    @State private var cardInputs: [(question: String, answer: String, tags: String)] = [("", "", "")]
    @State private var errorMessage: String?
    @State private var shakeTrigger = 0

    var body: some View {
        NavigationStack {
            ZStack {
                PatternBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        fieldSection(title: "Topic Title") {
                            TextField("Enter topic name", text: $title)
                                .fieldStyle()
                                .shake(trigger: shakeTrigger)
                        }

                        fieldSection(title: "Topic Tags (comma separated)") {
                            TextField("Biology, Exam", text: $topicTagsText).fieldStyle()
                        }

                        ForEach(Array(cardInputs.enumerated()), id: \.offset) { index, _ in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Card \(index + 1)")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                TextField("Question", text: questionBinding(for: index)).fieldStyle()
                                TextField("Answer", text: answerBinding(for: index)).fieldStyle()
                                TextField("Tags (optional)", text: tagsBinding(for: index)).fieldStyle()
                            }
                        }

                        Button {
                            HapticManager.lightTap()
                            cardInputs.append(("", "", ""))
                        } label: {
                            Label("Add Card", systemImage: "plus.circle")
                                .foregroundStyle(Color("AppAccent"))
                        }

                        if let errorMessage {
                            Text(errorMessage).font(.caption).foregroundStyle(.red)
                        }

                        PrimaryButton(title: "Save Topic") { saveTopic() }
                    }
                    .padding(16)
                }
                .appScrollStyle()
            }
            .appScreenStyle()
            .navigationTitle("New Topic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { HapticManager.lightTap(); isPresented = false }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }

    @ViewBuilder
    private func fieldSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(Color("AppTextSecondary"))
            content()
        }
    }

    private func parseTags(_ text: String) -> [String] {
        text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    private func questionBinding(for index: Int) -> Binding<String> {
        Binding(get: { cardInputs[index].question }, set: { cardInputs[index].question = $0 })
    }

    private func answerBinding(for index: Int) -> Binding<String> {
        Binding(get: { cardInputs[index].answer }, set: { cardInputs[index].answer = $0 })
    }

    private func tagsBinding(for index: Int) -> Binding<String> {
        Binding(get: { cardInputs[index].tags }, set: { cardInputs[index].tags = $0 })
    }

    private func saveTopic() {
        let cards = cardInputs.map { item in
            (question: item.question, answer: item.answer, tags: parseTags(item.tags))
        }
        let success = store.addTopic(title: title, tags: parseTags(topicTagsText), cards: cards)
        if success {
            HapticManager.mediumImpact()
            SoundManager.playSuccess()
            isPresented = false
        } else {
            HapticManager.warning()
            errorMessage = "Please enter a topic title and at least one valid card."
            shakeTrigger += 1
        }
    }
}

private extension View {
    func fieldStyle() -> some View {
        self
            .padding(12)
            .background(Color("AppSurface"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(Color("AppTextPrimary"))
    }
}
