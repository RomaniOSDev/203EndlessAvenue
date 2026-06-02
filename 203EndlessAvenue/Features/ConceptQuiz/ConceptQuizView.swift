import SwiftUI

struct ConceptQuizView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = ConceptQuizViewModel()

    var body: some View {
        ZStack {
            PatternBackground()
            ScrollView {
                VStack(spacing: 0) {
                    ScreenHeader(title: "Concept Quiz", subtitle: headerSubtitle)

                    switch viewModel.phase {
                    case .setup:
                        quizSetupContent
                    case .active:
                        quizActiveContent
                    case .results:
                        quizResultsContent
                    }
                }
            }
            .appScrollStyle()

            SuccessCheckmarkOverlay(isVisible: $viewModel.showCompletionCheckmark)
        }
        .appScreenStyle()
        .onAppear {
            if viewModel.selectedTopicID == nil { viewModel.selectedTopicID = store.topics.first?.id }
            viewModel.loadQuestions(from: store)
        }
        .onChange(of: store.topics) { _ in viewModel.loadQuestions(from: store) }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSubtitle: String {
        switch viewModel.phase {
        case .setup:
            return viewModel.allQuestions.isEmpty
                ? "Add topics to begin"
                : "\(viewModel.allQuestions.count) questions available"
        case .active:
            return "Question \(viewModel.currentIndex + 1) of \(viewModel.sessionQuestions.count)"
        case .results:
            return "Session complete"
        }
    }

    // MARK: - Setup

    private var quizSetupContent: some View {
        VStack(spacing: 16) {
            quizHeroBanner

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatTile(title: "Available", value: "\(viewModel.allQuestions.count)", icon: "brain.head.profile")
                StatTile(title: "Avg Score", value: store.completedQuizzes.isEmpty ? "—" : "\(store.averageQuizScore)%", icon: "percent")
                StatTile(title: "Completed", value: "\(store.quizzesCompleted)", icon: "checkmark.circle.fill")
                StatTile(title: "Flagged", value: "\(store.flaggedQuestions.count)", icon: "flag.fill")
            }
            .padding(.horizontal, 16)

            AppCard(accentBorder: true) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Quiz Source")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(QuizSourceFilter.allCases) { filter in
                            QuizFilterTile(
                                filter: filter,
                                isSelected: viewModel.sourceFilter == filter
                            ) {
                                viewModel.sourceFilter = filter
                                viewModel.loadQuestions(from: store)
                            }
                        }
                    }

                    if viewModel.sourceFilter == .singleTopic, !store.topics.isEmpty {
                        Picker("Topic", selection: Binding(
                            get: { viewModel.selectedTopicID ?? store.topics.first?.id ?? "" },
                            set: { viewModel.selectedTopicID = $0; viewModel.loadQuestions(from: store) }
                        )) {
                            ForEach(store.topics) { topic in
                                Text(topic.title).tag(topic.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color("AppAccent"))
                    }

                    Text("Session Size")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                        .padding(.top, 4)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(QuizSessionSize.allCases) { size in
                                FilterChip(
                                    title: size.title,
                                    isSelected: viewModel.sessionSize == size
                                ) {
                                    viewModel.sessionSize = size
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            if viewModel.allQuestions.isEmpty {
                quizEmptyState
            } else {
                PrimaryButton(title: "Start Quiz", icon: "play.fill") {
                    viewModel.startSession(from: store)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    private var quizHeroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeWidgetQuiz")
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipped()

            LinearGradient(
                colors: [.clear, Color("AppBackground").opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Multiple Choice Practice")
                    .font(.headline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Forward & reverse questions from your flashcards")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .appCardChrome(cornerRadius: 20, accentBorder: true, elevation: .elevated)
        .padding(.horizontal, 16)
    }

    private var quizEmptyState: some View {
        VStack(spacing: 16) {
            EmptyStateView(
                systemImage: emptyStateIcon,
                message: emptyStateMessage
            )

            if store.topics.isEmpty {
                PrimaryButton(title: "Load Sample Topics", icon: "square.stack.3d.up.fill") {
                    store.loadSampleContent()
                    viewModel.loadQuestions(from: store)
                    HapticManager.success()
                    SoundManager.playSuccess()
                }
                .padding(.horizontal, 16)
            } else if viewModel.sourceFilter != .allTopics {
                PrimaryButton(title: "Switch to All Topics", icon: "books.vertical.fill") {
                    viewModel.sourceFilter = .allTopics
                    viewModel.loadQuestions(from: store)
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 24)
    }

    private var emptyStateMessage: String {
        if store.topics.isEmpty {
            return "Quiz questions are built from your flashcards. Add a topic in Explorer, or load sample content to try the quiz right away."
        }
        switch viewModel.sourceFilter {
        case .flaggedOnly:
            return "No flagged questions yet. Flag items during a quiz, or switch to All Topics."
        case .bookmarkedOnly:
            return "No bookmarked cards yet. Bookmark cards in Topic Progress, or switch to All Topics."
        case .singleTopic:
            return "This topic has no cards. Pick another topic or add flashcards in Explorer."
        case .allTopics:
            return "No questions available. Add flashcards with a question and answer in Explorer."
        }
    }

    private var emptyStateIcon: String {
        store.topics.isEmpty ? "tray.full" : "line.3.horizontal.decrease.circle"
    }

    // MARK: - Active

    @ViewBuilder
    private var quizActiveContent: some View {
        if let question = viewModel.currentQuestion {
            VStack(spacing: 16) {
                QuizProgressHeader(
                    current: viewModel.currentIndex + 1,
                    total: viewModel.sessionQuestions.count,
                    fraction: viewModel.progressFraction,
                    answered: viewModel.answeredInSession
                )
                .padding(.horizontal, 16)

                QuizActiveQuestionCard(
                    question: question,
                    questionNumber: viewModel.currentIndex + 1,
                    topicTitle: store.topics.first(where: { $0.id == question.topicID })?.title,
                    selectedIndex: viewModel.selectedAnswers[question.id],
                    isFlagged: store.flaggedQuestions.contains(viewModel.flagID(for: question)),
                    onSelect: { viewModel.selectAnswer(questionID: question.id, optionIndex: $0) },
                    onToggleFlag: { store.toggleFlagQuestion(viewModel.flagID(for: question)) }
                )
                .padding(.horizontal, 16)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(question.id)

                HStack(spacing: 12) {
                    Button {
                        viewModel.goToPrevious()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .font(.subheadline.bold())
                            .foregroundStyle(viewModel.currentIndex > 0 ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .appInsetFieldChrome(cornerRadius: 14)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.currentIndex == 0)

                    Button {
                        viewModel.submitCurrent(store: store)
                    } label: {
                        Text(viewModel.currentIndex == viewModel.sessionQuestions.count - 1 ? "Finish" : "Next")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .appPrimaryButtonChrome(cornerRadius: 14)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.selectedAnswers[question.id] == nil)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Results

    private var quizResultsContent: some View {
        VStack(spacing: 16) {
            AppCard(accentBorder: true, elevated: true) {
                VStack(spacing: 16) {
                    if let score = viewModel.lastScore {
                        ScoreRingView(score: score)
                        Text(score >= 80 ? "Excellent work!" : score >= 50 ? "Good effort!" : "Keep practicing")
                            .font(.title3.bold())
                            .foregroundStyle(AppDesign.Gradients.title)
                        Text("\(viewModel.correctCount) of \(viewModel.sessionQuestions.count) correct")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .padding(.horizontal, 16)

            SectionHeader(title: "Review Answers")

            LazyVStack(spacing: 10) {
                ForEach(Array(viewModel.sessionQuestions.enumerated()), id: \.element.id) { index, question in
                    QuizReviewRow(
                        number: index + 1,
                        question: question,
                        topicTitle: store.topics.first(where: { $0.id == question.topicID })?.title,
                        selectedIndex: viewModel.selectedAnswers[question.id],
                        isCorrect: viewModel.isCorrect(question)
                    )
                }
            }
            .padding(.horizontal, 16)

            PrimaryButton(title: "Try Again", icon: "arrow.clockwise") {
                viewModel.retryQuiz(from: store)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Components

private struct QuizFilterTile: View {
    let filter: QuizSourceFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                IconBadge(systemName: filter.icon, size: 36, filled: isSelected)
                Text(filter.title)
                    .font(.caption2.bold())
                    .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(AppDesign.Gradients.accentTint) : AnyShapeStyle(Color.clear))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                isSelected ? Color("AppAccent").opacity(0.4) : Color("AppTextSecondary").opacity(0.15),
                                lineWidth: 1
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded { HapticManager.lightTap() })
    }
}

private struct QuizProgressHeader: View {
    let current: Int
    let total: Int
    let fraction: Double
    let answered: Int

    var body: some View {
        AppCard {
            VStack(spacing: 12) {
                HStack {
                    Label("Question \(current)/\(total)", systemImage: "list.number")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Text("\(answered) answered")
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color("AppBackground"))
                        Capsule()
                            .fill(AppDesign.Gradients.primaryHorizontal)
                            .frame(width: geo.size.width * fraction)
                    }
                }
                .frame(height: 8)
            }
        }
    }
}

private struct QuizActiveQuestionCard: View {
    let question: QuizQuestion
    let questionNumber: Int
    let topicTitle: String?
    let selectedIndex: Int?
    let isFlagged: Bool
    let onSelect: (Int) -> Void
    let onToggleFlag: () -> Void

    var body: some View {
        AppCard(accentBorder: true, elevated: true) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Q\(questionNumber)")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppDesign.Gradients.primaryHorizontal)
                        .clipShape(Capsule())

                    if question.isReverse {
                        StatusPill(text: "Reverse", style: .inProgress)
                    }

                    Spacer()

                    Button(action: onToggleFlag) {
                        Image(systemName: isFlagged ? "flag.fill" : "flag")
                            .foregroundStyle(isFlagged ? Color("AppAccent") : Color("AppTextSecondary"))
                    }
                    .buttonStyle(.plain)
                }

                if let topicTitle {
                    Text(topicTitle)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                }

                Text(question.question)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 10) {
                    ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                        QuizOptionCell(
                            text: option,
                            letter: optionLetter(index),
                            isSelected: selectedIndex == index
                        ) {
                            onSelect(index)
                        }
                    }
                }
            }
        }
    }

    private func optionLetter(_ index: Int) -> String {
        ["A", "B", "C", "D"][safe: index] ?? "?"
    }
}

private struct QuizReviewRow: View {
    let number: Int
    let question: QuizQuestion
    let topicTitle: String?
    let selectedIndex: Int?
    let isCorrect: Bool

    var body: some View {
        AppCard(accentBorder: isCorrect, isHighlighted: !isCorrect) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isCorrect ? AnyShapeStyle(AppDesign.Gradients.primary) : AnyShapeStyle(Color.red.opacity(0.25)))
                        .frame(width: 32, height: 32)
                    Image(systemName: isCorrect ? "checkmark" : "xmark")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Q\(number)")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppTextSecondary"))
                        if let topicTitle {
                            Text("· \(topicTitle)")
                                .font(.caption2)
                                .foregroundStyle(Color("AppAccent"))
                                .lineLimit(1)
                        }
                    }
                    Text(question.question)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(3)
                    if let selectedIndex, question.options.indices.contains(selectedIndex) {
                        Text("Your answer: \(question.options[selectedIndex])")
                            .font(.caption)
                            .foregroundStyle(isCorrect ? Color("AppAccent") : Color.red.opacity(0.85))
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
