import Foundation

enum CardStatus: String, Codable, CaseIterable {
    case none
    case inProgress
    case known
}

struct Flashcard: Codable, Identifiable, Equatable {
    let id: String
    var question: String
    var answer: String
    var status: CardStatus
    var tags: [String]

    init(
        id: String = UUID().uuidString,
        question: String,
        answer: String,
        status: CardStatus = .none,
        tags: [String] = []
    ) {
        self.id = id
        self.question = question
        self.answer = answer
        self.status = status
        self.tags = tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        question = try container.decode(String.self, forKey: .question)
        answer = try container.decode(String.self, forKey: .answer)
        status = try container.decodeIfPresent(CardStatus.self, forKey: .status) ?? .none
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }
}

struct Topic: Codable, Identifiable, Equatable {
    let id: String
    var title: String
    var cards: [Flashcard]
    var tags: [String]

    init(id: String = UUID().uuidString, title: String, cards: [Flashcard] = [], tags: [String] = []) {
        self.id = id
        self.title = title
        self.cards = cards
        self.tags = tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        cards = try container.decodeIfPresent([Flashcard].self, forKey: .cards) ?? []
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }

    var learnedCount: Int {
        cards.filter { $0.status == .known }.count
    }

    var progressPercentage: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(learnedCount) / Double(cards.count) * 100
    }

    var isFullyLearned: Bool {
        !cards.isEmpty && learnedCount == cards.count
    }
}

struct QuizQuestion: Codable, Identifiable, Equatable {
    let id: String
    let topicID: String
    var question: String
    var options: [String]
    var correctIndex: Int

    init(
        id: String = UUID().uuidString,
        topicID: String,
        question: String,
        options: [String],
        correctIndex: Int
    ) {
        self.id = id
        self.topicID = topicID
        self.question = question
        self.options = options
        self.correctIndex = correctIndex
    }
}

enum QuizSourceFilter: String, Codable, CaseIterable, Identifiable {
    case allTopics
    case singleTopic
    case flaggedOnly
    case bookmarkedOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .allTopics: return "All Topics"
        case .singleTopic: return "Single Topic"
        case .flaggedOnly: return "Flagged Only"
        case .bookmarkedOnly: return "Bookmarked Only"
        }
    }

    var icon: String {
        switch self {
        case .allTopics: return "books.vertical.fill"
        case .singleTopic: return "folder.fill"
        case .flaggedOnly: return "flag.fill"
        case .bookmarkedOnly: return "bookmark.fill"
        }
    }
}

enum QuizSessionSize: Int, CaseIterable, Identifiable {
    case five = 5
    case ten = 10
    case fifteen = 15
    case twenty = 20
    case all = 0

    var id: Int { rawValue }

    var title: String {
        rawValue == 0 ? "All" : "\(rawValue) Questions"
    }
}

enum QuizPhase {
    case setup
    case active
    case results
}

struct QuizResult: Codable, Identifiable, Equatable {
    let id: String
    let date: Date
    let score: Int
    let totalQuestions: Int
    let topicID: String?
    let filterLabel: String

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        score: Int,
        totalQuestions: Int,
        topicID: String? = nil,
        filterLabel: String = "All Topics"
    ) {
        self.id = id
        self.date = date
        self.score = score
        self.totalQuestions = totalQuestions
        self.topicID = topicID
        self.filterLabel = filterLabel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        score = try container.decode(Int.self, forKey: .score)
        totalQuestions = try container.decode(Int.self, forKey: .totalQuestions)
        topicID = try container.decodeIfPresent(String.self, forKey: .topicID)
        filterLabel = try container.decodeIfPresent(String.self, forKey: .filterLabel) ?? "All Topics"
    }
}

struct WeeklyStats: Codable, Equatable {
    var timeSpent: Int
    var conceptsReviewed: Int

    init(timeSpent: Int = 0, conceptsReviewed: Int = 0) {
        self.timeSpent = timeSpent
        self.conceptsReviewed = conceptsReviewed
    }
}

struct ConceptConnection: Codable, Identifiable, Equatable {
    let id: String
    let sourceID: String
    let targetID: String
    var label: String

    init(id: String = UUID().uuidString, sourceID: String, targetID: String, label: String = "related to") {
        self.id = id
        self.sourceID = sourceID
        self.targetID = targetID
        self.label = label
    }
}

struct NodePosition: Codable, Equatable {
    var x: Double
    var y: Double
}

struct DailyActivity: Codable, Equatable {
    var cardsReviewed: Int
    var quizzesCompleted: Int
    var minutesStudied: Int

    init(cardsReviewed: Int = 0, quizzesCompleted: Int = 0, minutesStudied: Int = 0) {
        self.cardsReviewed = cardsReviewed
        self.quizzesCompleted = quizzesCompleted
        self.minutesStudied = minutesStudied
    }
}

struct WeeklyGoals: Codable, Equatable {
    var cardsTarget: Int
    var quizzesTarget: Int
    var cardsProgress: Int
    var quizzesProgress: Int
    var weekStartDate: Date

    init(
        cardsTarget: Int = 20,
        quizzesTarget: Int = 3,
        cardsProgress: Int = 0,
        quizzesProgress: Int = 0,
        weekStartDate: Date = Date()
    ) {
        self.cardsTarget = cardsTarget
        self.quizzesTarget = quizzesTarget
        self.cardsProgress = cardsProgress
        self.quizzesProgress = quizzesProgress
        self.weekStartDate = weekStartDate
    }

    var cardsFraction: Double {
        guard cardsTarget > 0 else { return 0 }
        return min(1, Double(cardsProgress) / Double(cardsTarget))
    }

    var quizzesFraction: Double {
        guard quizzesTarget > 0 else { return 0 }
        return min(1, Double(quizzesProgress) / Double(quizzesTarget))
    }
}

struct CardReference: Identifiable, Equatable {
    let topic: Topic
    let card: Flashcard

    var id: String { card.id }
}

struct ExportBundle: Codable {
    var topics: [Topic]
    var cardsLearned: [String: Int]
    var completedQuizzes: [QuizResult]
    var flaggedQuestions: [String]
    var learnedPercentage: [String: Double]
    var weeklyStats: [String: WeeklyStats]
    var bookmarkedCardIDs: [String]
    var exploredTopicIDs: [String]
    var cardSpacedData: [String: CardSpacedRepetition]
    var conceptConnections: [ConceptConnection]
    var nodePositions: [String: NodePosition]
    var dailyActivityLog: [String: DailyActivity]
    var weeklyGoals: WeeklyGoals
    var reviewStreakDays: Int
    var lastReviewActivityDate: Date?
    var achievementsUnlocked: [String: Date]
    var totalSessionsCompleted: Int
    var totalMinutesUsed: Int
    var streakDays: Int
    var cardsReviewed: Int
    var quizzesCompleted: Int
}

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let systemImage: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(id: "first_steps", title: "First Steps", description: "Reviewed your first set of cards.", systemImage: "star.fill"),
        AchievementDefinition(id: "quiz_beginner", title: "Quiz Beginner", description: "Completed your first quiz.", systemImage: "brain.head.profile"),
        AchievementDefinition(id: "topic_explorer", title: "Topic Explorer", description: "Explored five different topics.", systemImage: "map.fill"),
        AchievementDefinition(id: "consistent_learner", title: "Consistent Learner", description: "Studied for seven consecutive days.", systemImage: "calendar"),
        AchievementDefinition(id: "getting_going", title: "Getting Going", description: "Reached 10 items.", systemImage: "arrow.up.circle.fill"),
        AchievementDefinition(id: "power_user", title: "Power User", description: "Reached 50 items.", systemImage: "bolt.fill"),
        AchievementDefinition(id: "active_user", title: "Active User", description: "Completed 10 sessions.", systemImage: "flame.fill"),
        AchievementDefinition(id: "dedicated_user", title: "Dedicated User", description: "Completed 50 sessions.", systemImage: "crown.fill"),
        AchievementDefinition(id: "topic_creator", title: "Topic Creator", description: "Created five topics.", systemImage: "folder.fill.badge.plus"),
        AchievementDefinition(id: "review_streak", title: "Review Streak", description: "Reviewed cards seven days in a row.", systemImage: "repeat.circle.fill"),
        AchievementDefinition(id: "bookmark_collector", title: "Bookmark Collector", description: "Bookmarked ten items.", systemImage: "bookmark.fill"),
        AchievementDefinition(id: "mastery", title: "Mastery", description: "Reached 100% on a topic.", systemImage: "checkmark.seal.fill")
    ]
}

enum MainTab: Int, CaseIterable, Identifiable {
    case home
    case explorer
    case study
    case achievements
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .explorer: return "Explorer"
        case .study: return "Study"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .explorer: return "book.fill"
        case .study: return "graduationcap.fill"
        case .achievements: return "trophy.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

enum StudyDestination: String, CaseIterable, Identifiable {
    case reviewDue
    case quickReview
    case quiz
    case quizHistory
    case progress
    case conceptMap
    case insights
    case weeklyGoals

    var id: String { rawValue }

    var title: String {
        switch self {
        case .reviewDue: return "Review Due Today"
        case .quickReview: return "Quick Review"
        case .quiz: return "Concept Quiz"
        case .quizHistory: return "Quiz History"
        case .progress: return "Topic Progress"
        case .conceptMap: return "Concept Map"
        case .insights: return "Study Insights"
        case .weeklyGoals: return "Weekly Goals"
        }
    }

    var icon: String {
        switch self {
        case .reviewDue: return "calendar.badge.clock"
        case .quickReview: return "bolt.fill"
        case .quiz: return "questionmark.circle.fill"
        case .quizHistory: return "clock.arrow.circlepath"
        case .progress: return "chart.bar.fill"
        case .conceptMap: return "point.3.connected.trianglepath.dotted"
        case .insights: return "chart.xyaxis.line"
        case .weeklyGoals: return "target"
        }
    }

    var subtitle: String {
        switch self {
        case .reviewDue: return "Cards scheduled for today"
        case .quickReview: return "Short 5–10 card session"
        case .quiz: return "Multiple-choice practice"
        case .quizHistory: return "Past quiz results"
        case .progress: return "Track topic completion"
        case .conceptMap: return "Visual concept connections"
        case .insights: return "Activity and performance"
        case .weeklyGoals: return "Weekly study targets"
        }
    }
}

enum StudySection: String, CaseIterable, Identifiable {
    case quiz
    case progress

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quiz: return "Concept Quiz"
        case .progress: return "Topic Progress"
        }
    }
}
