import SwiftUI

struct TagFilterBar: View {
    let tags: [String]
    @Binding var selectedTag: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedTag == nil) {
                    HapticManager.lightTap()
                    selectedTag = nil
                }
                ForEach(tags, id: \.self) { tag in
                    FilterChip(title: tag, isSelected: selectedTag == tag) {
                        HapticManager.lightTap()
                        selectedTag = tag
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 8)
        .opacity(tags.isEmpty ? 0 : 1)
        .frame(height: tags.isEmpty ? 0 : nil)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(isSelected ? AnyShapeStyle(AppDesign.Gradients.primaryHorizontal) : AnyShapeStyle(AppDesign.Gradients.surface))
                        .overlay {
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(isSelected ? 0.12 : 0.06),
                                            Color("AppTextSecondary").opacity(isSelected ? 0 : 0.18)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                )
        }
        .buttonStyle(.plain)
    }
}

struct SelfCheckButtons: View {
    let onGotIt: () -> Void
    let onNeedReview: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onNeedReview) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Need Review")
                }
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .appInsetFieldChrome(cornerRadius: 12)
            }
            .buttonStyle(.plain)

            Button(action: onGotIt) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                    Text("Got It")
                }
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .appPrimaryButtonChrome(cornerRadius: 12)
            }
            .buttonStyle(.plain)
        }
    }
}

struct ReviewCardView: View {
    let reference: CardReference
    let isFlipped: Bool
    let showSelfCheck: Bool
    let onFlip: () -> Void
    let onGotIt: () -> Void
    let onNeedReview: () -> Void

    var body: some View {
        AppCard(accentBorder: isFlipped) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    StatusPill(text: reference.topic.title, style: .inProgress)
                    Spacer()
                    StatusPill(text: isFlipped ? "Answer" : "Question", style: .neutral)
                }

                Text(isFlipped ? reference.card.answer : reference.card.question)
                    .font(.body)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 60)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        HapticManager.lightTap()
                        onFlip()
                    }

                if isFlipped && showSelfCheck {
                    SelfCheckButtons(onGotIt: onGotIt, onNeedReview: onNeedReview)
                } else if !isFlipped {
                    Text("Tap to reveal")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }
}
