import Foundation

struct CardSpacedRepetition: Codable, Equatable {
    var nextReviewDate: Date
    var easeFactor: Double
    var intervalDays: Int
    var repetitions: Int

    init(
        nextReviewDate: Date = Date(),
        easeFactor: Double = 2.5,
        intervalDays: Int = 0,
        repetitions: Int = 0
    ) {
        self.nextReviewDate = nextReviewDate
        self.easeFactor = easeFactor
        self.intervalDays = intervalDays
        self.repetitions = repetitions
    }
}

enum SM2Scheduler {
    /// Quality 0–5. Got it ≈ 5, Need review ≈ 2.
    static func schedule(current: CardSpacedRepetition, quality: Int) -> CardSpacedRepetition {
        let q = min(5, max(0, quality))
        var updated = current

        if q < 3 {
            updated.repetitions = 0
            updated.intervalDays = 1
        } else {
            switch updated.repetitions {
            case 0:
                updated.intervalDays = 1
            case 1:
                updated.intervalDays = 6
            default:
                updated.intervalDays = max(1, Int((Double(updated.intervalDays) * updated.easeFactor).rounded()))
            }
            updated.repetitions += 1
        }

        let delta = 0.1 - Double(5 - q) * (0.08 + Double(5 - q) * 0.02)
        updated.easeFactor = max(1.3, updated.easeFactor + delta)

        let calendar = Calendar.current
        updated.nextReviewDate = calendar.date(byAdding: .day, value: updated.intervalDays, to: calendar.startOfDay(for: Date())) ?? Date()
        return updated
    }
}
