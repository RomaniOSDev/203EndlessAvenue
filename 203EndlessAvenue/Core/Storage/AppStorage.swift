import Foundation
import Combine

final class AppDataStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let topics = "topics"
        static let cardsLearned = "cardsLearned"
        static let totalCards = "totalCards"
        static let lastViewedTopicID = "lastViewedTopicID"
        static let quizProgress = "quizProgress"
        static let completedQuizzes = "completedQuizzes"
        static let flaggedQuestions = "flaggedQuestions"
        static let learnedPercentage = "learnedPercentage"
        static let weeklyStats = "weeklyStats"
        static let bookmarkedCardIDs = "bookmarkedCardIDs"
        static let cardsReviewed = "cardsReviewed"
        static let quizzesCompleted = "quizzesCompleted"
        static let topicsCompleted = "topicsCompleted"
        static let exploredTopicIDs = "exploredTopicIDs"
        static let cardSpacedData = "cardSpacedData"
        static let conceptConnections = "conceptConnections"
        static let nodePositions = "nodePositions"
        static let dailyActivityLog = "dailyActivityLog"
        static let weeklyGoals = "weeklyGoals"
        static let reviewStreakDays = "reviewStreakDays"
        static let lastReviewActivityDate = "lastReviewActivityDate"
        static let didSeedStarterContent = "didSeedStarterContent"
    }

    @Published var hasSeenOnboarding: Bool { didSet { save(hasSeenOnboarding, for: Keys.hasSeenOnboarding) } }
    @Published var totalSessionsCompleted: Int { didSet { save(totalSessionsCompleted, for: Keys.totalSessionsCompleted) } }
    @Published var totalMinutesUsed: Int { didSet { save(totalMinutesUsed, for: Keys.totalMinutesUsed) } }
    @Published var streakDays: Int { didSet { save(streakDays, for: Keys.streakDays) } }
    @Published var lastActivityDate: Date? { didSet { saveOptionalDate(lastActivityDate, for: Keys.lastActivityDate) } }
    @Published var achievementsUnlocked: [String: Date] { didSet { saveCodable(achievementsUnlocked, for: Keys.achievementsUnlocked) } }
    @Published var topics: [Topic] { didSet { saveCodable(topics, for: Keys.topics); syncDerivedCounts() } }
    @Published var cardsLearned: [String: Int] { didSet { saveCodable(cardsLearned, for: Keys.cardsLearned) } }
    @Published var totalCards: Int { didSet { save(totalCards, for: Keys.totalCards) } }
    @Published var lastViewedTopicID: String? { didSet { saveOptionalString(lastViewedTopicID, for: Keys.lastViewedTopicID) } }
    @Published var quizProgress: Int { didSet { save(quizProgress, for: Keys.quizProgress) } }
    @Published var completedQuizzes: [QuizResult] { didSet { saveCodable(completedQuizzes, for: Keys.completedQuizzes) } }
    @Published var flaggedQuestions: [String] { didSet { saveCodable(flaggedQuestions, for: Keys.flaggedQuestions) } }
    @Published var learnedPercentage: [String: Double] { didSet { saveCodable(learnedPercentage, for: Keys.learnedPercentage) } }
    @Published var weeklyStats: [String: WeeklyStats] { didSet { saveCodable(weeklyStats, for: Keys.weeklyStats) } }
    @Published var bookmarkedCardIDs: [String] { didSet { saveCodable(bookmarkedCardIDs, for: Keys.bookmarkedCardIDs) } }
    @Published var cardsReviewed: Int { didSet { save(cardsReviewed, for: Keys.cardsReviewed) } }
    @Published var quizzesCompleted: Int { didSet { save(quizzesCompleted, for: Keys.quizzesCompleted) } }
    @Published var topicsCompleted: Int { didSet { save(topicsCompleted, for: Keys.topicsCompleted) } }
    @Published var exploredTopicIDs: Set<String> { didSet { saveCodable(Array(exploredTopicIDs), for: Keys.exploredTopicIDs) } }
    @Published var cardSpacedData: [String: CardSpacedRepetition] { didSet { saveCodable(cardSpacedData, for: Keys.cardSpacedData) } }
    @Published var conceptConnections: [ConceptConnection] { didSet { saveCodable(conceptConnections, for: Keys.conceptConnections) } }
    @Published var nodePositions: [String: NodePosition] { didSet { saveCodable(nodePositions, for: Keys.nodePositions) } }
    @Published var dailyActivityLog: [String: DailyActivity] { didSet { saveCodable(dailyActivityLog, for: Keys.dailyActivityLog) } }
    @Published var weeklyGoals: WeeklyGoals { didSet { saveCodable(weeklyGoals, for: Keys.weeklyGoals) } }
    @Published var reviewStreakDays: Int { didSet { save(reviewStreakDays, for: Keys.reviewStreakDays) } }
    @Published var lastReviewActivityDate: Date? { didSet { saveOptionalDate(lastReviewActivityDate, for: Keys.lastReviewActivityDate) } }
    @Published var pendingAchievement: AchievementDefinition?

    private var achievementQueue: [AchievementDefinition] = []
    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()

    init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadCodable([String: Date].self, from: defaults, key: Keys.achievementsUnlocked) ?? [:]
        topics = Self.loadCodable([Topic].self, from: defaults, key: Keys.topics) ?? []
        cardsLearned = Self.loadCodable([String: Int].self, from: defaults, key: Keys.cardsLearned) ?? [:]
        totalCards = defaults.integer(forKey: Keys.totalCards)
        lastViewedTopicID = defaults.string(forKey: Keys.lastViewedTopicID)
        quizProgress = defaults.integer(forKey: Keys.quizProgress)
        completedQuizzes = Self.loadCodable([QuizResult].self, from: defaults, key: Keys.completedQuizzes) ?? []
        flaggedQuestions = Self.loadCodable([String].self, from: defaults, key: Keys.flaggedQuestions) ?? []
        learnedPercentage = Self.loadCodable([String: Double].self, from: defaults, key: Keys.learnedPercentage) ?? [:]
        weeklyStats = Self.loadCodable([String: WeeklyStats].self, from: defaults, key: Keys.weeklyStats) ?? [:]
        bookmarkedCardIDs = Self.loadCodable([String].self, from: defaults, key: Keys.bookmarkedCardIDs) ?? []
        cardsReviewed = defaults.integer(forKey: Keys.cardsReviewed)
        quizzesCompleted = defaults.integer(forKey: Keys.quizzesCompleted)
        topicsCompleted = defaults.integer(forKey: Keys.topicsCompleted)
        let explored = Self.loadCodable([String].self, from: defaults, key: Keys.exploredTopicIDs) ?? []
        exploredTopicIDs = Set(explored)
        cardSpacedData = Self.loadCodable([String: CardSpacedRepetition].self, from: defaults, key: Keys.cardSpacedData) ?? [:]
        conceptConnections = Self.loadCodable([ConceptConnection].self, from: defaults, key: Keys.conceptConnections) ?? []
        nodePositions = Self.loadCodable([String: NodePosition].self, from: defaults, key: Keys.nodePositions) ?? [:]
        dailyActivityLog = Self.loadCodable([String: DailyActivity].self, from: defaults, key: Keys.dailyActivityLog) ?? [:]
        weeklyGoals = Self.loadCodable(WeeklyGoals.self, from: defaults, key: Keys.weeklyGoals) ?? WeeklyGoals()
        reviewStreakDays = defaults.integer(forKey: Keys.reviewStreakDays)
        lastReviewActivityDate = defaults.object(forKey: Keys.lastReviewActivityDate) as? Date

        syncDerivedCounts()
        refreshWeeklyGoalsIfNeeded()
        seedStarterContentIfNeeded()

        NotificationCenter.default.publisher(for: .dataReset)
            .sink { [weak self] _ in self?.reloadFromDefaults() }
            .store(in: &cancellables)
    }

    // MARK: - Derived

    var allTags: [String] {
        var tags = Set<String>()
        for topic in topics {
            tags.formUnion(topic.tags)
            for card in topic.cards { tags.formUnion(card.tags) }
        }
        return tags.sorted()
    }

    var topicsCreatedCount: Int { topics.count }

    var masteredTopicsCount: Int { topics.filter(\.isFullyLearned).count }

    var averageQuizScore: Int {
        guard !completedQuizzes.isEmpty else { return 0 }
        let total = completedQuizzes.reduce(0) { $0 + $1.score }
        return total / completedQuizzes.count
    }

    var weakestTopic: Topic? {
        topics.filter { !$0.cards.isEmpty }.min { ($0.progressPercentage) < ($1.progressPercentage) }
    }

    var bestStudyWeekday: String {
        var counts: [Int: Int] = [:]
        let calendar = Calendar.current
        for (key, activity) in dailyActivityLog where activity.cardsReviewed + activity.quizzesCompleted > 0 {
            if let date = Self.dateFromKey(key) {
                let weekday = calendar.component(.weekday, from: date)
                counts[weekday, default: 0] += activity.cardsReviewed + activity.quizzesCompleted
            }
        }
        guard let best = counts.max(by: { $0.value < $1.value })?.key else { return "—" }
        return calendar.weekdaySymbols[best - 1]
    }

    func activityForLastDays(_ days: Int) -> [(date: Date, activity: DailyActivity)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<days).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let key = Self.dayKey(for: date)
            return (date, dailyActivityLog[key] ?? DailyActivity())
        }.reversed()
    }

    var quizQuestions: [QuizQuestion] {
        quizQuestions(filter: .allTopics, topicID: nil)
    }

    func quizQuestions(filter: QuizSourceFilter, topicID: String?) -> [QuizQuestion] {
        var cards: [CardReference] = []
        switch filter {
        case .allTopics:
            cards = allCardReferences()
        case .singleTopic:
            guard let topicID, let topic = topics.first(where: { $0.id == topicID }) else { return [] }
            cards = topic.cards.map { CardReference(topic: topic, card: $0) }
        case .flaggedOnly:
            cards = allCardReferences().filter { flaggedQuestions.contains($0.card.id) }
        case .bookmarkedOnly:
            cards = bookmarkedCards().map { CardReference(topic: $0.topic, card: $0.card) }
        }
        return cards.flatMap { ref -> [QuizQuestion] in
            let forward = makeForwardQuestion(for: ref, pool: cards)
            let reverse = makeReverseQuestion(for: ref, pool: cards)
            return [forward, reverse]
        }
    }

    private func makeForwardQuestion(for ref: CardReference, pool: [CardReference]) -> QuizQuestion {
        let generated = generateQuizOptions(
            correctAnswer: ref.card.answer,
            topic: ref.topic,
            cardID: ref.card.id,
            pool: pool
        )
        return QuizQuestion(
            id: ref.card.id,
            topicID: ref.topic.id,
            question: ref.card.question,
            options: generated.options,
            correctIndex: generated.correctIndex
        )
    }

    private func makeReverseQuestion(for ref: CardReference, pool: [CardReference]) -> QuizQuestion {
        let generated = generateQuizOptions(
            correctAnswer: ref.card.question,
            topic: ref.topic,
            cardID: ref.card.id,
            pool: pool,
            useQuestionsAsPool: true
        )
        return QuizQuestion(
            id: "\(ref.card.id)_reverse",
            topicID: ref.topic.id,
            question: "Which question matches this answer?\n\n\"\(ref.card.answer)\"",
            options: generated.options,
            correctIndex: generated.correctIndex
        )
    }

    func cardsDueToday() -> [CardReference] {
        let today = Calendar.current.startOfDay(for: Date())
        return allCardReferences().filter { ref in
            let sr = cardSpacedData[ref.card.id] ?? CardSpacedRepetition()
            return Calendar.current.startOfDay(for: sr.nextReviewDate) <= today
        }
    }

    func dueCount(for topicID: String) -> Int {
        cardsDueToday().filter { $0.topic.id == topicID }.count
    }

    func nextReviewLabel(for cardID: String) -> String? {
        guard let sr = cardSpacedData[cardID] else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        let due = Calendar.current.startOfDay(for: sr.nextReviewDate)
        if due <= today { return "Due today" }
        let days = Calendar.current.dateComponents([.day], from: today, to: due).day ?? 0
        return days == 1 ? "Due tomorrow" : "Due in \(days)d"
    }

    func quickReviewCards(limit: Int = 10) -> [CardReference] {
        let due = cardsDueToday()
        let dueIDs = Set(due.map(\.card.id))
        let inProgress = allCardReferences().filter { $0.card.status == .inProgress && !dueIDs.contains($0.card.id) }
        return Array((due + inProgress).prefix(limit))
    }

    func allCardReferences(matchingTag tag: String? = nil) -> [CardReference] {
        topics.flatMap { topic in
            topic.cards
                .filter { card in
                    guard let tag, !tag.isEmpty else { return true }
                    return topic.tags.contains(tag) || card.tags.contains(tag)
                }
                .map { CardReference(topic: topic, card: $0) }
        }
    }

    func filteredTopics(by tag: String?) -> [Topic] {
        guard let tag, !tag.isEmpty else { return topics }
        return topics.filter { $0.tags.contains(tag) || $0.cards.contains { $0.tags.contains(tag) } }
    }

    /// Loads demo topics on first launch so Quiz and Explorer are not empty.
    func seedStarterContentIfNeeded() {
        guard topics.isEmpty else { return }
        guard !defaults.bool(forKey: Keys.didSeedStarterContent) else { return }
        loadSampleContent(markSeeded: true)
    }

    func loadSampleContent(markSeeded: Bool = false) {
        let samples: [(title: String, tags: [String], cards: [(question: String, answer: String, tags: [String])])] = [
            (
                "Biology Basics",
                ["Biology", "Science"],
                [
                    ("What is photosynthesis?", "The process plants use to convert light into energy", ["Plants"]),
                    ("What is DNA?", "Deoxyribonucleic acid, the molecule that carries genetic information", ["Genetics"]),
                    ("What is a cell?", "The smallest unit of life", ["Cells"]),
                    ("What is mitosis?", "Cell division that produces two identical daughter cells", ["Cells"])
                ]
            ),
            (
                "World History",
                ["History", "Exam"],
                [
                    ("When did World War II end?", "1945", ["WWII"]),
                    ("Who was the first US president?", "George Washington", ["USA"]),
                    ("What was the Renaissance?", "A period of cultural rebirth in Europe from the 14th to 17th century", ["Europe"]),
                    ("What is the Magna Carta?", "A 1215 charter limiting the power of the English king", ["Law"])
                ]
            ),
            (
                "Programming",
                ["Tech", "CS"],
                [
                    ("What is a variable?", "A named storage location for data in a program", ["Basics"]),
                    ("What is an API?", "Application Programming Interface — a way for programs to communicate", ["Web"]),
                    ("What is recursion?", "When a function calls itself to solve a smaller instance of a problem", ["Algorithms"]),
                    ("What is Git?", "A distributed version control system for tracking code changes", ["Tools"])
                ]
            )
        ]

        for sample in samples {
            _ = addTopic(title: sample.title, tags: sample.tags, cards: sample.cards)
        }

        if markSeeded {
            defaults.set(true, forKey: Keys.didSeedStarterContent)
        }
    }

    // MARK: - Onboarding & Activity

    func completeOnboarding() {
        hasSeenOnboarding = true
        recordActivity(minutes: 1)
    }

    func recordActivity(minutes: Int = 1, cardsReviewedDelta: Int = 0, quizCompleted: Bool = false) {
        updateStreak()
        totalMinutesUsed += minutes
        lastActivityDate = Date()
        logDailyActivity(cardsReviewedDelta: cardsReviewedDelta, quizCompleted: quizCompleted, minutes: minutes)
        refreshWeeklyGoalsIfNeeded()
    }

    func recordReviewActivity() {
        updateReviewStreak()
        recordActivity(cardsReviewedDelta: 1)
        weeklyGoals.cardsProgress += 1
    }

    // MARK: - Topics & Cards

    func addTopic(title: String, tags: [String], cards: [(question: String, answer: String, tags: [String])]) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return false }

        let validCards = cards.compactMap { item -> Flashcard? in
            let question = item.question.trimmingCharacters(in: .whitespacesAndNewlines)
            let answer = item.answer.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !question.isEmpty, !answer.isEmpty else { return nil }
            return Flashcard(question: question, answer: answer, tags: item.tags)
        }
        guard !validCards.isEmpty else { return false }

        let topic = Topic(title: trimmedTitle, cards: validCards, tags: tags)
        topics.append(topic)
        cardsLearned[topic.id] = 0
        learnedPercentage[topic.id] = 0
        weeklyStats[topic.id] = WeeklyStats()
        for card in validCards {
            cardSpacedData[card.id] = CardSpacedRepetition()
            ensureNodePosition(for: card.id, index: topics.count)
        }
        ensureNodePosition(for: topic.id, index: topics.count)
        recordActivity()
        checkAchievements()
        return true
    }

    func updateTopic(_ topicID: String, title: String, tags: [String], cards: [Flashcard]) -> Bool {
        guard let index = topics.firstIndex(where: { $0.id == topicID }) else { return false }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !cards.isEmpty else { return false }

        let oldCards = topics[index].cards
        topics[index].title = trimmed
        topics[index].tags = tags
        topics[index].cards = cards

        for card in cards where cardSpacedData[card.id] == nil {
            cardSpacedData[card.id] = CardSpacedRepetition()
        }
        let removed = Set(oldCards.map(\.id)).subtracting(cards.map(\.id))
        for id in removed {
            cardSpacedData.removeValue(forKey: id)
            bookmarkedCardIDs.removeAll { $0 == id }
            flaggedQuestions.removeAll { $0 == id }
        }
        updateTopicProgress(topicID: topicID)
        recordActivity()
        checkAchievements()
        return true
    }

    func toggleTopicExpansion(_ topicID: String) {
        lastViewedTopicID = topicID
        exploredTopicIDs.insert(topicID)
        recordActivity()
        updateTopicsCompletedCount()
        checkAchievements()
    }

    func markCard(_ cardID: String, in topicID: String, status: CardStatus) {
        guard let topicIndex = topics.firstIndex(where: { $0.id == topicID }),
              let cardIndex = topics[topicIndex].cards.firstIndex(where: { $0.id == cardID }) else { return }

        let previousStatus = topics[topicIndex].cards[cardIndex].status
        topics[topicIndex].cards[cardIndex].status = status

        if status == .known && previousStatus != .known {
            cardsReviewed += 1
            cardsLearned[topicID, default: 0] += 1
        } else if previousStatus == .known && status != .known {
            cardsReviewed = max(0, cardsReviewed - 1)
            cardsLearned[topicID, default: 0] = max(0, cardsLearned[topicID, default: 0] - 1)
        }

        updateTopicProgress(topicID: topicID)
        recordActivity()
        checkAchievements()
    }

    func selfCheckCard(_ cardID: String, in topicID: String, gotIt: Bool) {
        let quality = gotIt ? 5 : 2
        let current = cardSpacedData[cardID] ?? CardSpacedRepetition()
        cardSpacedData[cardID] = SM2Scheduler.schedule(current: current, quality: quality)
        markCard(cardID, in: topicID, status: gotIt ? .known : .inProgress)
        recordReviewActivity()
        checkAchievements()
    }

    func deleteCard(_ cardID: String, from topicID: String) {
        guard let topicIndex = topics.firstIndex(where: { $0.id == topicID }) else { return }
        if let card = topics[topicIndex].cards.first(where: { $0.id == cardID }), card.status == .known {
            cardsReviewed = max(0, cardsReviewed - 1)
            cardsLearned[topicID, default: 0] = max(0, cardsLearned[topicID, default: 0] - 1)
        }
        topics[topicIndex].cards.removeAll { $0.id == cardID }
        bookmarkedCardIDs.removeAll { $0 == cardID }
        flaggedQuestions.removeAll { $0 == cardID }
        cardSpacedData.removeValue(forKey: cardID)
        nodePositions.removeValue(forKey: cardID)
        conceptConnections.removeAll { $0.sourceID == cardID || $0.targetID == cardID }

        if topics[topicIndex].cards.isEmpty {
            let topicID = topics[topicIndex].id
            topics.remove(at: topicIndex)
            cardsLearned.removeValue(forKey: topicID)
            learnedPercentage.removeValue(forKey: topicID)
            weeklyStats.removeValue(forKey: topicID)
            nodePositions.removeValue(forKey: topicID)
            conceptConnections.removeAll { $0.sourceID == topicID || $0.targetID == topicID }
        } else {
            updateTopicProgress(topicID: topicID)
        }
        recordActivity()
        checkAchievements()
    }

    func toggleBookmark(cardID: String, topicID: String) {
        if bookmarkedCardIDs.contains(cardID) {
            bookmarkedCardIDs.removeAll { $0 == cardID }
        } else {
            bookmarkedCardIDs.append(cardID)
        }
        var stats = weeklyStats[topicID] ?? WeeklyStats()
        stats.conceptsReviewed += 1
        weeklyStats[topicID] = stats
        recordActivity()
        checkAchievements()
    }

    func isBookmarked(_ cardID: String) -> Bool { bookmarkedCardIDs.contains(cardID) }

    func toggleFlagQuestion(_ questionID: String) {
        if flaggedQuestions.contains(questionID) {
            flaggedQuestions.removeAll { $0 == questionID }
        } else {
            flaggedQuestions.append(questionID)
        }
        HapticManager.lightTap()
    }

    // MARK: - Quiz

    func submitQuiz(answers: [String: Int], questions: [QuizQuestion], filter: QuizSourceFilter, topicID: String?) -> Int {
        guard !questions.isEmpty else { return 0 }

        var correct = 0
        for question in questions where answers[question.id] == question.correctIndex {
            correct += 1
        }

        let score = Int((Double(correct) / Double(questions.count)) * 100)
        let label: String
        switch filter {
        case .allTopics: label = "All Topics"
        case .singleTopic: label = topics.first(where: { $0.id == topicID })?.title ?? "Single Topic"
        case .flaggedOnly: label = "Flagged Only"
        case .bookmarkedOnly: label = "Bookmarked Only"
        }

        let result = QuizResult(score: score, totalQuestions: questions.count, topicID: topicID, filterLabel: label)
        completedQuizzes.insert(result, at: 0)
        quizzesCompleted += 1
        totalSessionsCompleted += 1
        quizProgress = min(quizProgress + 1, questions.count)
        weeklyGoals.quizzesProgress += 1

        if let topicID {
            var stats = weeklyStats[topicID] ?? WeeklyStats()
            stats.timeSpent += 5
            stats.conceptsReviewed += 1
            weeklyStats[topicID] = stats
            exploredTopicIDs.insert(topicID)
        }

        recordActivity(minutes: 5, quizCompleted: true)
        updateTopicsCompletedCount()
        checkAchievements()
        return score
    }

    func completeQuickReviewSession(minutes: Int, cardsCount: Int) {
        totalSessionsCompleted += 1
        weeklyGoals.cardsProgress += cardsCount
        recordActivity(minutes: max(1, minutes), cardsReviewedDelta: cardsCount)
        checkAchievements()
    }

    // MARK: - Concept Map

    func addConnection(from sourceID: String, to targetID: String, label: String = "related to") -> Bool {
        guard sourceID != targetID else { return false }
        let exists = conceptConnections.contains {
            ($0.sourceID == sourceID && $0.targetID == targetID) || ($0.sourceID == targetID && $0.targetID == sourceID)
        }
        guard !exists else { return false }
        conceptConnections.append(ConceptConnection(sourceID: sourceID, targetID: targetID, label: label))
        recordActivity()
        return true
    }

    func removeConnection(_ id: String) {
        conceptConnections.removeAll { $0.id == id }
    }

    func updateNodePosition(_ nodeID: String, position: NodePosition) {
        nodePositions[nodeID] = position
    }

    func mapNodes() -> [(id: String, title: String, isTopic: Bool)] {
        var nodes: [(String, String, Bool)] = topics.map { ($0.id, $0.title, true) }
        for topic in topics {
            for card in topic.cards {
                nodes.append((card.id, card.question, false))
            }
        }
        return nodes
    }

    // MARK: - Import / Export

    func exportJSON() -> Data? {
        let bundle = ExportBundle(
            topics: topics,
            cardsLearned: cardsLearned,
            completedQuizzes: completedQuizzes,
            flaggedQuestions: flaggedQuestions,
            learnedPercentage: learnedPercentage,
            weeklyStats: weeklyStats,
            bookmarkedCardIDs: bookmarkedCardIDs,
            exploredTopicIDs: Array(exploredTopicIDs),
            cardSpacedData: cardSpacedData,
            conceptConnections: conceptConnections,
            nodePositions: nodePositions,
            dailyActivityLog: dailyActivityLog,
            weeklyGoals: weeklyGoals,
            reviewStreakDays: reviewStreakDays,
            lastReviewActivityDate: lastReviewActivityDate,
            achievementsUnlocked: achievementsUnlocked,
            totalSessionsCompleted: totalSessionsCompleted,
            totalMinutesUsed: totalMinutesUsed,
            streakDays: streakDays,
            cardsReviewed: cardsReviewed,
            quizzesCompleted: quizzesCompleted
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(bundle)
    }

    func importJSON(_ data: Data) -> Bool {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let bundle = try? decoder.decode(ExportBundle.self, from: data) else { return false }

        topics = bundle.topics
        cardsLearned = bundle.cardsLearned
        completedQuizzes = bundle.completedQuizzes
        flaggedQuestions = bundle.flaggedQuestions
        learnedPercentage = bundle.learnedPercentage
        weeklyStats = bundle.weeklyStats
        bookmarkedCardIDs = bundle.bookmarkedCardIDs
        exploredTopicIDs = Set(bundle.exploredTopicIDs)
        cardSpacedData = bundle.cardSpacedData
        conceptConnections = bundle.conceptConnections
        nodePositions = bundle.nodePositions
        dailyActivityLog = bundle.dailyActivityLog
        weeklyGoals = bundle.weeklyGoals
        reviewStreakDays = bundle.reviewStreakDays
        lastReviewActivityDate = bundle.lastReviewActivityDate
        achievementsUnlocked = bundle.achievementsUnlocked
        totalSessionsCompleted = bundle.totalSessionsCompleted
        totalMinutesUsed = bundle.totalMinutesUsed
        streakDays = bundle.streakDays
        cardsReviewed = bundle.cardsReviewed
        quizzesCompleted = bundle.quizzesCompleted
        syncDerivedCounts()
        updateTopicsCompletedCount()
        checkAchievements()
        return true
    }

    // MARK: - Reset & Achievements

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadCodable([String: Date].self, from: defaults, key: Keys.achievementsUnlocked) ?? [:]
        topics = Self.loadCodable([Topic].self, from: defaults, key: Keys.topics) ?? []
        cardsLearned = Self.loadCodable([String: Int].self, from: defaults, key: Keys.cardsLearned) ?? [:]
        totalCards = defaults.integer(forKey: Keys.totalCards)
        lastViewedTopicID = defaults.string(forKey: Keys.lastViewedTopicID)
        quizProgress = defaults.integer(forKey: Keys.quizProgress)
        completedQuizzes = Self.loadCodable([QuizResult].self, from: defaults, key: Keys.completedQuizzes) ?? []
        flaggedQuestions = Self.loadCodable([String].self, from: defaults, key: Keys.flaggedQuestions) ?? []
        learnedPercentage = Self.loadCodable([String: Double].self, from: defaults, key: Keys.learnedPercentage) ?? [:]
        weeklyStats = Self.loadCodable([String: WeeklyStats].self, from: defaults, key: Keys.weeklyStats) ?? [:]
        bookmarkedCardIDs = Self.loadCodable([String].self, from: defaults, key: Keys.bookmarkedCardIDs) ?? []
        cardsReviewed = defaults.integer(forKey: Keys.cardsReviewed)
        quizzesCompleted = defaults.integer(forKey: Keys.quizzesCompleted)
        topicsCompleted = defaults.integer(forKey: Keys.topicsCompleted)
        exploredTopicIDs = Set(Self.loadCodable([String].self, from: defaults, key: Keys.exploredTopicIDs) ?? [])
        cardSpacedData = Self.loadCodable([String: CardSpacedRepetition].self, from: defaults, key: Keys.cardSpacedData) ?? [:]
        conceptConnections = Self.loadCodable([ConceptConnection].self, from: defaults, key: Keys.conceptConnections) ?? []
        nodePositions = Self.loadCodable([String: NodePosition].self, from: defaults, key: Keys.nodePositions) ?? [:]
        dailyActivityLog = Self.loadCodable([String: DailyActivity].self, from: defaults, key: Keys.dailyActivityLog) ?? [:]
        weeklyGoals = Self.loadCodable(WeeklyGoals.self, from: defaults, key: Keys.weeklyGoals) ?? WeeklyGoals()
        reviewStreakDays = defaults.integer(forKey: Keys.reviewStreakDays)
        lastReviewActivityDate = defaults.object(forKey: Keys.lastReviewActivityDate) as? Date
        pendingAchievement = nil
        achievementQueue.removeAll()
        syncDerivedCounts()
    }

    func isAchievementUnlocked(_ id: String) -> Bool { achievementsUnlocked[id] != nil }

    func dismissAchievementBanner() {
        pendingAchievement = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.showNextAchievementIfNeeded()
        }
    }

    func bookmarkedCards() -> [(topic: Topic, card: Flashcard)] {
        var results: [(Topic, Flashcard)] = []
        for topic in topics {
            for card in topic.cards where bookmarkedCardIDs.contains(card.id) {
                results.append((topic, card))
            }
        }
        return results
    }

    func updateWeeklyGoalTargets(cards: Int, quizzes: Int) {
        weeklyGoals.cardsTarget = max(1, cards)
        weeklyGoals.quizzesTarget = max(1, quizzes)
    }

    // MARK: - Private

    private func ensureNodePosition(for nodeID: String, index: Int) {
        guard nodePositions[nodeID] == nil else { return }
        let angle = Double(index) * 0.9
        nodePositions[nodeID] = NodePosition(x: cos(angle) * 120 + 160, y: sin(angle) * 100 + 200)
    }

    private func logDailyActivity(cardsReviewedDelta: Int, quizCompleted: Bool, minutes: Int) {
        let key = Self.dayKey(for: Date())
        var activity = dailyActivityLog[key] ?? DailyActivity()
        activity.cardsReviewed += cardsReviewedDelta
        if quizCompleted { activity.quizzesCompleted += 1 }
        activity.minutesStudied += minutes
        dailyActivityLog[key] = activity
    }

    private func refreshWeeklyGoalsIfNeeded() {
        let calendar = Calendar.current
        let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        if !calendar.isDate(weeklyGoals.weekStartDate, equalTo: currentWeekStart, toGranularity: .weekOfYear) {
            weeklyGoals = WeeklyGoals(
                cardsTarget: weeklyGoals.cardsTarget,
                quizzesTarget: weeklyGoals.quizzesTarget,
                weekStartDate: currentWeekStart
            )
        }
    }

    private func updateReviewStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let last = lastReviewActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 0 { return }
            reviewStreakDays = diff == 1 ? reviewStreakDays + 1 : 1
        } else {
            reviewStreakDays = 1
        }
        lastReviewActivityDate = today
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let lastDate = lastActivityDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if dayDiff == 0 { return }
            streakDays = dayDiff == 1 ? streakDays + 1 : 1
        } else {
            streakDays = 1
        }
    }

    private func updateTopicProgress(topicID: String) {
        guard let topic = topics.first(where: { $0.id == topicID }) else { return }
        cardsLearned[topicID] = topic.learnedCount
        learnedPercentage[topicID] = topic.progressPercentage
        var stats = weeklyStats[topicID] ?? WeeklyStats()
        stats.conceptsReviewed = topic.learnedCount
        weeklyStats[topicID] = stats
        updateTopicsCompletedCount()
        if topic.isFullyLearned { checkAchievements() }
    }

    private func updateTopicsCompletedCount() {
        topicsCompleted = exploredTopicIDs.count
    }

    private func syncDerivedCounts() {
        totalCards = topics.reduce(0) { $0 + $1.cards.count }
        for topic in topics {
            cardsLearned[topic.id] = topic.learnedCount
            learnedPercentage[topic.id] = topic.progressPercentage
            for card in topic.cards where cardSpacedData[card.id] == nil {
                cardSpacedData[card.id] = CardSpacedRepetition()
            }
        }
    }

    private func generateQuizOptions(
        correctAnswer: String,
        topic: Topic,
        cardID: String,
        pool: [CardReference],
        useQuestionsAsPool: Bool = false
    ) -> (options: [String], correctIndex: Int) {
        var distractorPool = Set<String>()

        for ref in pool where ref.card.id != cardID {
            let value = useQuestionsAsPool ? ref.card.question : ref.card.answer
            if !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, value != correctAnswer {
                distractorPool.insert(value)
            }
        }

        for otherTopic in topics where otherTopic.id != topic.id {
            for card in otherTopic.cards where card.id != cardID {
                let value = useQuestionsAsPool ? card.question : card.answer
                if !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, value != correctAnswer {
                    distractorPool.insert(value)
                }
            }
        }

        var distractors = Array(distractorPool).shuffled().prefix(3).map { String($0) }
        let fallbacks = [
            "This applies to a different concept",
            "Partially correct but incomplete",
            "Not the best match here"
        ]
        var fallbackIndex = 0
        while distractors.count < 3 {
            let candidate = fallbacks[fallbackIndex % fallbacks.count]
            fallbackIndex += 1
            if candidate != correctAnswer, !distractors.contains(candidate) {
                distractors.append(candidate)
            } else {
                distractors.append("None of the above")
            }
        }

        var options = [correctAnswer] + distractors.prefix(3)
        options.shuffle()
        return (options, options.firstIndex(of: correctAnswer) ?? 0)
    }

    private func checkAchievements() {
        let conditions: [(String, () -> Bool)] = [
            ("first_steps", { self.cardsReviewed >= 1 }),
            ("quiz_beginner", { self.quizzesCompleted >= 1 }),
            ("topic_explorer", { self.topicsCompleted >= 5 }),
            ("consistent_learner", { self.streakDays >= 7 }),
            ("getting_going", { self.cardsReviewed >= 10 }),
            ("power_user", { self.cardsReviewed >= 50 }),
            ("active_user", { self.quizzesCompleted >= 10 }),
            ("dedicated_user", { self.quizzesCompleted >= 50 }),
            ("topic_creator", { self.topicsCreatedCount >= 5 }),
            ("review_streak", { self.reviewStreakDays >= 7 }),
            ("bookmark_collector", { self.bookmarkedCardIDs.count >= 10 }),
            ("mastery", { self.masteredTopicsCount >= 1 })
        ]
        for (id, condition) in conditions where condition() && achievementsUnlocked[id] == nil {
            achievementsUnlocked[id] = Date()
            if let achievement = AchievementDefinition.all.first(where: { $0.id == id }) {
                enqueueAchievement(achievement)
            }
        }
    }

    private func enqueueAchievement(_ achievement: AchievementDefinition) {
        achievementQueue.append(achievement)
        showNextAchievementIfNeeded()
    }

    private func showNextAchievementIfNeeded() {
        guard pendingAchievement == nil, let next = achievementQueue.first else { return }
        achievementQueue.removeFirst()
        pendingAchievement = next
        HapticManager.success()
        SoundManager.playSuccess()
    }

    private func save(_ value: Bool, for key: String) { defaults.set(value, forKey: key) }
    private func save(_ value: Int, for key: String) { defaults.set(value, forKey: key) }
    private func saveOptionalString(_ value: String?, for key: String) { defaults.set(value, forKey: key) }
    private func saveOptionalDate(_ value: Date?, for key: String) { defaults.set(value, forKey: key) }
    private func saveCodable<T: Encodable>(_ value: T, for key: String) {
        if let data = try? JSONEncoder().encode(value) { defaults.set(data, forKey: key) }
    }

    private static func loadCodable<T: Decodable>(_ type: T.Type, from defaults: UserDefaults, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func dateFromKey(_ key: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: key)
    }
}
