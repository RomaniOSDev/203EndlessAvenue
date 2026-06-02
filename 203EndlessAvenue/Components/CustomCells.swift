import SwiftUI

// MARK: - Card Shell

struct AppCard<Content: View>: View {
    var accentBorder: Bool = false
    var isHighlighted: Bool = false
    var elevated: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .appCardChrome(
                accentBorder: accentBorder,
                isHighlighted: isHighlighted,
                elevation: elevated ? .elevated : .soft
            )
    }
}

struct StatusPill: View {
    enum Style { case known, inProgress, due, neutral }

    let text: String
    let style: Style

    var body: some View {
        Text(text)
            .font(.caption2.bold())
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(background)
            .clipShape(Capsule())
    }

    private var foreground: Color {
        switch style {
        case .known: return Color("AppTextPrimary")
        case .inProgress: return Color("AppTextPrimary")
        case .due: return Color("AppTextPrimary")
        case .neutral: return Color("AppTextSecondary")
        }
    }

    private var background: some ShapeStyle {
        switch style {
        case .known:
            return AnyShapeStyle(AppDesign.Gradients.primaryHorizontal)
        case .inProgress:
            return AnyShapeStyle(LinearGradient(
                colors: [Color("AppAccent").opacity(0.7), Color("AppAccent").opacity(0.45)],
                startPoint: .leading,
                endPoint: .trailing
            ))
        case .due:
            return AnyShapeStyle(AppDesign.Gradients.surface)
        case .neutral:
            return AnyShapeStyle(Color("AppBackground"))
        }
    }
}

struct IconBadge: View {
    let systemName: String
    var size: CGFloat = 44
    var filled: Bool = true

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    filled
                        ? AnyShapeStyle(AppDesign.Gradients.primary)
                        : AnyShapeStyle(AppDesign.Gradients.surface)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(filled ? AppDesign.Gradients.surfaceHighlight : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom))
                }
                .frame(width: size, height: size)
            Image(systemName: systemName)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(filled ? Color("AppTextPrimary") : Color("AppTextSecondary"))
        }
    }
}

struct ProgressRingView: View {
    let percentage: Double
    var lineWidth: CGFloat = 5
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppTextSecondary").opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(1, percentage / 100))
                .stroke(
                    AppDesign.Gradients.ring,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(Int(percentage))%")
                .font(.system(size: size * 0.24, weight: .bold))
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .frame(width: size, height: size)
    }
}

struct CountBadge: View {
    let count: Int

    var body: some View {
        if count > 0 {
            Text("\(count)")
                .font(.caption2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppDesign.Gradients.primaryHorizontal)
                .clipShape(Capsule())
                .appShadow(.soft)
        }
    }
}

struct TagRow: View {
    let tags: [String]

    var body: some View {
        if !tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .foregroundStyle(Color("AppAccent"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppDesign.Gradients.accentTint)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color("AppAccent").opacity(0.25), lineWidth: 0.5)
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Topic Cell

struct TopicCell: View {
    let topic: Topic
    let isExpanded: Bool
    var dueCount: Int = 0
    let onToggle: () -> Void
    var onEdit: (() -> Void)?

    var body: some View {
        AppCard(accentBorder: isExpanded) {
            HStack(spacing: 14) {
                ProgressRingView(percentage: topic.progressPercentage, size: 52)

                VStack(alignment: .leading, spacing: 6) {
                    Text(topic.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    HStack(spacing: 8) {
                        Label("\(topic.learnedCount)/\(topic.cards.count)", systemImage: "checkmark.circle")
                        if dueCount > 0 {
                            StatusPill(text: "\(dueCount) due", style: .due)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))

                    TagRow(tags: topic.tags)
                }

                Spacer(minLength: 0)

                VStack(spacing: 10) {
                    if let onEdit {
                        Button {
                            HapticManager.lightTap()
                            onEdit()
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color("AppPrimary"))
                        }
                        .buttonStyle(.plain)
                    }

                    Button(action: onToggle) {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color("AppAccent"))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Flashcard Cell

struct FlashcardCell: View {
    let card: Flashcard
    let isFlipped: Bool
    let isPulsing: Bool
    var dueLabel: String?
    let onFlip: () -> Void
    let onMarkKnown: () -> Void
    let onMarkInProgress: () -> Void
    let onGotIt: () -> Void
    let onNeedReview: () -> Void

    var body: some View {
        AppCard(accentBorder: isFlipped, isHighlighted: isPulsing) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    StatusPill(text: isFlipped ? "Answer" : "Question", style: .neutral)
                    Spacer()
                    if let dueLabel {
                        StatusPill(text: dueLabel, style: .due)
                    }
                    statusIcon
                }

                ZStack {
                    cardFace(text: card.question, visible: !isFlipped)
                        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                        .opacity(isFlipped ? 0 : 1)
                    cardFace(text: card.answer, visible: isFlipped)
                        .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                        .opacity(isFlipped ? 1 : 0)
                }
                .frame(minHeight: 72)
                .contentShape(Rectangle())
                .onTapGesture {
                    HapticManager.lightTap()
                    onFlip()
                }

                TagRow(tags: card.tags)

                if isFlipped {
                    SelfCheckButtons(onGotIt: onGotIt, onNeedReview: onNeedReview)
                } else {
                    Text("Tap to reveal answer")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .scaleEffect(isPulsing ? 1.02 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPulsing)
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: isFlipped)
        .contextMenu {
            Button { onMarkKnown() } label: { Label("Mark Known", systemImage: "checkmark") }
            Button { onMarkInProgress() } label: { Label("In Progress", systemImage: "clock") }
        }
    }

    @ViewBuilder
    private func cardFace(text: String, visible: Bool) -> some View {
        Text(text)
            .font(.body)
            .foregroundStyle(Color("AppTextPrimary"))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch card.status {
        case .known:
            StatusPill(text: "Known", style: .known)
        case .inProgress:
            StatusPill(text: "Learning", style: .inProgress)
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Study Hub Cell

struct StudyHubCell: View {
    let destination: StudyDestination
    var badgeCount: Int = 0

    var body: some View {
        AppCard(accentBorder: badgeCount > 0) {
            HStack(spacing: 14) {
                IconBadge(systemName: destination.icon)

                VStack(alignment: .leading, spacing: 5) {
                    Text(destination.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(destination.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }

                Spacer()

                if badgeCount > 0 {
                    CountBadge(count: badgeCount)
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
            }
        }
    }
}

// MARK: - Quiz Cells

struct QuizQuestionCell: View {
    let question: QuizQuestion
    let topicTitle: String?
    let selectedIndex: Int?
    let isSubmitted: Bool
    let isFlagged: Bool
    let onSelect: (Int) -> Void
    let onSubmit: () -> Void
    let onToggleFlag: () -> Void

    var body: some View {
        AppCard(accentBorder: isSubmitted) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        if let topicTitle {
                            Text(topicTitle)
                                .font(.caption)
                                .foregroundStyle(Color("AppAccent"))
                        }
                        Text(question.question)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        if isFlagged {
                            Image(systemName: "flag.fill").foregroundStyle(Color("AppAccent"))
                        }
                        if isSubmitted {
                            Image(systemName: "checkmark.seal.fill").foregroundStyle(Color("AppPrimary"))
                        }
                    }
                }

                VStack(spacing: 8) {
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

                HStack(spacing: 10) {
                    Button {
                        HapticManager.lightTap()
                        onToggleFlag()
                    } label: {
                        Label(isFlagged ? "Unflag" : "Flag", systemImage: "flag")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button(action: onSubmit) {
                        Text("Submit")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .appPrimaryButtonChrome(cornerRadius: 20)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contextMenu {
            Button { onToggleFlag() } label: {
                Label(isFlagged ? "Unflag" : "Flag", systemImage: "flag")
            }
        }
    }

    private func optionLetter(_ index: Int) -> String {
        ["A", "B", "C", "D"][safe: index] ?? "?"
    }
}

struct QuizOptionCell: View {
    let text: String
    let letter: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(letter)
                    .font(.caption.bold())
                    .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .frame(width: 28, height: 28)
                    .background {
                        Circle()
                            .fill(isSelected ? AnyShapeStyle(AppDesign.Gradients.primary) : AnyShapeStyle(Color("AppBackground")))
                    }
                    .clipShape(Circle())

                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(AppDesign.Gradients.accentTint) : AnyShapeStyle(Color("AppBackground")))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                isSelected
                                    ? LinearGradient(
                                        colors: [Color("AppPrimary"), Color("AppAccent")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom),
                                lineWidth: isSelected ? 1.5 : 0
                            )
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

struct QuizHistoryCell: View {
    let result: QuizResult

    var body: some View {
        AppCard(accentBorder: result.score >= 80) {
            HStack(spacing: 16) {
                ScoreRingView(score: result.score)

                VStack(alignment: .leading, spacing: 6) {
                    Text(result.filterLabel)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(result.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    StatusPill(
                        text: result.score >= 80 ? "Strong" : (result.score >= 50 ? "Good" : "Review"),
                        style: result.score >= 80 ? .known : .inProgress
                    )
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(result.totalQuestions)")
                        .font(.title2.bold())
                        .foregroundStyle(Color("AppAccent"))
                    Text("questions")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }
}

struct ScoreRingView: View {
    let score: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppTextSecondary").opacity(0.2), lineWidth: 5)
            Circle()
                .trim(from: 0, to: Double(score) / 100)
                .stroke(
                    score >= 80 ? AnyShapeStyle(AppDesign.Gradients.ring) : AnyShapeStyle(scoreColor),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(score)%")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .frame(width: 56, height: 56)
    }

    private var scoreColor: Color {
        score >= 80 ? Color("AppPrimary") : (score >= 50 ? Color("AppAccent") : Color("AppTextSecondary"))
    }
}

// MARK: - Progress & Bookmark Cells

struct TopicProgressCell: View {
    let topic: Topic
    let percentage: Double
    let weeklyStats: WeeklyStats
    let isExpanded: Bool
    let isPulsing: Bool
    let onToggle: () -> Void

    var body: some View {
        AppCard(accentBorder: isExpanded, isHighlighted: isPulsing) {
            Button(action: onToggle) {
                HStack(spacing: 14) {
                    ProgressRingView(percentage: percentage, size: 54)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(topic.title)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(2)
                        HStack(spacing: 12) {
                            Label("\(weeklyStats.timeSpent)m", systemImage: "clock")
                            Label("\(weeklyStats.conceptsReviewed)", systemImage: "book")
                        }
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            .buttonStyle(.plain)
        }
    }
}

struct ProgressCardCell: View {
    let card: Flashcard
    let isBookmarked: Bool

    var body: some View {
        AppCard {
            HStack(spacing: 12) {
                IconBadge(systemName: statusIcon, size: 36, filled: card.status != .none)

                VStack(alignment: .leading, spacing: 4) {
                    Text(card.question)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(2)
                    if card.status != .none {
                        StatusPill(
                            text: card.status == .known ? "Known" : "Learning",
                            style: card.status == .known ? .known : .inProgress
                        )
                    }
                }

                Spacer()

                if isBookmarked {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }

    private var statusIcon: String {
        switch card.status {
        case .known: return "checkmark"
        case .inProgress: return "clock"
        case .none: return "questionmark"
        }
    }
}

struct BookmarkCell: View {
    let topicTitle: String
    let question: String
    let answer: String

    var body: some View {
        AppCard(accentBorder: true) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    IconBadge(systemName: "bookmark.fill", size: 32)
                    Text(topicTitle)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                    Spacer()
                }
                Text(question)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(answer)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }
}

// MARK: - Achievement & Stats

struct AchievementCell: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool
    let unlockedDate: Date?

    var body: some View {
        AppCard(accentBorder: isUnlocked) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            isUnlocked
                                ? AnyShapeStyle(AppDesign.Gradients.primary)
                                : AnyShapeStyle(AppDesign.Gradients.surface)
                        )
                        .frame(width: 60, height: 60)
                        .overlay {
                            if isUnlocked {
                                Circle()
                                    .fill(AppDesign.Gradients.surfaceHighlight)
                                    .frame(width: 60, height: 60)
                            }
                        }

                    Image(systemName: achievement.systemImage)
                        .font(.title2)
                        .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary").opacity(0.4))

                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .offset(x: 22, y: 22)
                    }
                }

                Text(achievement.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(achievement.description)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)

                if isUnlocked, let date = unlockedDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 170)
        }
        .opacity(isUnlocked ? 1 : 0.72)
    }
}

struct StatTile: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(Color("AppAccent"))
                        .frame(width: 28, height: 28)
                        .background(AppDesign.Gradients.accentTint)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Spacer()
                }
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(AppDesign.Gradients.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }
}

struct SettingsCell: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            AppCard {
                HStack(spacing: 14) {
                    IconBadge(
                        systemName: icon,
                        size: 40,
                        filled: !isDestructive
                    )
                    Text(title)
                        .font(.body.weight(.medium))
                        .foregroundStyle(isDestructive ? .red : Color("AppTextPrimary"))
                    Spacer()
                    if !isDestructive {
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct SearchField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("AppTextSecondary"))
            TextField(placeholder, text: $text)
                .foregroundStyle(Color("AppTextPrimary"))
            if !text.isEmpty {
                Button {
                    HapticManager.lightTap()
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .appInsetFieldChrome()
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
