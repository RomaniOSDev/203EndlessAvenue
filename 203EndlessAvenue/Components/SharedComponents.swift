import SwiftUI

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            HapticManager.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .appPrimaryButtonChrome()
            .scaleEffect(isPressed ? 0.96 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(pressGesture)
    }

    private var pressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { isPressed = true }
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { isPressed = false }
            }
    }
}

struct EmptyStateView: View {
    let systemImage: String?
    let message: String
    var customIllustration: AnyView?
    @State private var appeared = false

    init(systemImage: String, message: String) {
        self.systemImage = systemImage
        self.message = message
        self.customIllustration = nil
    }

    init(message: String, @ViewBuilder illustration: () -> some View) {
        self.systemImage = nil
        self.message = message
        self.customIllustration = AnyView(illustration())
    }

    var body: some View {
        AppCard {
            VStack(spacing: 16) {
                Group {
                    if let customIllustration {
                        customIllustration
                    } else if let systemImage {
                        IconBadge(systemName: systemImage, size: 72, filled: false)
                    }
                }
                .scaleEffect(appeared ? 1 : 0.7)
                .opacity(appeared ? 1 : 0)

                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { appeared = true }
        }
    }
}

struct BookMagnifyingIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("AppPrimary").opacity(0.12))
                .frame(width: 88, height: 88)
            Circle()
                .stroke(AppDesign.Gradients.primary, lineWidth: 1.5)
                .frame(width: 88, height: 88)
            Image(systemName: "book.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color("AppPrimary"))
            Image(systemName: "magnifyingglass")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color("AppAccent"))
                .offset(x: 26, y: 20)
        }
        .frame(height: 88)
    }
}

struct SuccessCheckmarkOverlay: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            ZStack {
                Circle()
                    .fill(AppDesign.Gradients.surface)
                    .frame(width: 72, height: 72)
                Circle()
                    .stroke(AppDesign.Gradients.primary, lineWidth: 2)
                    .frame(width: 72, height: 72)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppDesign.Gradients.primary)
            }
            .appShadow(.elevated)
            .transition(.scale.combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 0.3)) { isVisible = false }
                }
            }
        }
    }
}

struct AchievementBannerView: View {
    let achievement: AchievementDefinition
    let onDismiss: () -> Void
    @State private var offset: CGFloat = -140

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(systemName: achievement.systemImage, size: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text("Achievement Unlocked")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            Spacer()
        }
        .padding(16)
        .background {
            AppCardBackground(accentBorder: true)
        }
        .appShadow(.elevated)
        .padding(.horizontal, 16)
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { offset = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.3)) { offset = -140 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onDismiss() }
            }
        }
    }
}

struct ScreenHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppDesign.Gradients.primaryHorizontal)
                    .frame(width: 4, height: 18)
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppDesign.Gradients.title)
            }
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(.leading, 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

struct SectionHeader: View {
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AppDesign.Gradients.primaryHorizontal)
                .frame(width: 3, height: 14)
            Text(title)
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppDesign.Gradients.accentTint)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
