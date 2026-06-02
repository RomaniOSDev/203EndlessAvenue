import SwiftUI
import Combine

final class ConceptQuizViewModel: ObservableObject {
    @Published var phase: QuizPhase = .setup
    @Published var allQuestions: [QuizQuestion] = []
    @Published var sessionQuestions: [QuizQuestion] = []
    @Published var currentIndex = 0
    @Published var selectedAnswers: [String: Int] = [:]
    @Published var showCompletionCheckmark = false
    @Published var lastScore: Int?
    @Published var correctCount = 0
    @Published var sourceFilter: QuizSourceFilter = .allTopics
    @Published var selectedTopicID: String?
    @Published var sessionSize: QuizSessionSize = .ten

    var currentQuestion: QuizQuestion? {
        guard sessionQuestions.indices.contains(currentIndex) else { return nil }
        return sessionQuestions[currentIndex]
    }

    var progressFraction: Double {
        guard !sessionQuestions.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(sessionQuestions.count)
    }

    var answeredInSession: Int {
        sessionQuestions.filter { selectedAnswers[$0.id] != nil }.count
    }

    func loadQuestions(from store: AppDataStore) {
        allQuestions = store.quizQuestions(filter: sourceFilter, topicID: selectedTopicID)
        if phase == .setup {
            sessionQuestions = []
            selectedAnswers = [:]
            lastScore = nil
            correctCount = 0
            currentIndex = 0
        }
    }

    func startSession(from store: AppDataStore) {
        loadQuestions(from: store)
        guard !allQuestions.isEmpty else {
            HapticManager.warning()
            return
        }

        let shuffled = allQuestions.shuffled()
        if sessionSize == .all {
            sessionQuestions = shuffled
        } else {
            sessionQuestions = Array(shuffled.prefix(sessionSize.rawValue))
        }

        selectedAnswers = [:]
        lastScore = nil
        correctCount = 0
        currentIndex = 0
        phase = .active
        HapticManager.mediumImpact()
        SoundManager.playTick()
    }

    func selectAnswer(questionID: String, optionIndex: Int) {
        HapticManager.lightTap()
        selectedAnswers[questionID] = optionIndex
    }

    func goToNext() {
        guard currentIndex < sessionQuestions.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentIndex += 1
        }
        HapticManager.lightTap()
    }

    func goToPrevious() {
        guard currentIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentIndex -= 1
        }
        HapticManager.lightTap()
    }

    func submitCurrent(store: AppDataStore) {
        guard let question = currentQuestion, selectedAnswers[question.id] != nil else {
            HapticManager.warning()
            return
        }

        if currentIndex < sessionQuestions.count - 1 {
            goToNext()
        } else {
            finishQuiz(store: store)
        }
    }

    func finishQuiz(store: AppDataStore) {
        guard !sessionQuestions.isEmpty else { return }
        guard sessionQuestions.allSatisfy({ selectedAnswers[$0.id] != nil }) else {
            HapticManager.warning()
            return
        }

        correctCount = sessionQuestions.filter { q in
            selectedAnswers[q.id] == q.correctIndex
        }.count

        let score = store.submitQuiz(
            answers: selectedAnswers,
            questions: sessionQuestions,
            filter: sourceFilter,
            topicID: selectedTopicID
        )
        lastScore = score
        phase = .results
        HapticManager.mediumImpact()
        SoundManager.playComplete()
        showCompletionCheckmark = true
        HapticManager.success()
        SoundManager.playSuccess()
    }

    func retryQuiz(from store: AppDataStore) {
        phase = .setup
        loadQuestions(from: store)
    }

    func flagID(for question: QuizQuestion) -> String {
        question.id.hasSuffix("_reverse")
            ? String(question.id.dropLast("_reverse".count))
            : question.id
    }

    func isCorrect(_ question: QuizQuestion) -> Bool {
        selectedAnswers[question.id] == question.correctIndex
    }
}

extension QuizQuestion {
    var isReverse: Bool { id.hasSuffix("_reverse") }
}
