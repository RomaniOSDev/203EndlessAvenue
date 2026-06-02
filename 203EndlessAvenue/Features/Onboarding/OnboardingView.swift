import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "HomeHero",
            icon: "point.3.connected.trianglepath.dotted",
            headline: "Explore Connections",
            description: "Discover how concepts interlink to expand your understanding.",
            features: ["Concept Map", "Topic Tags", "Smart Search"]
        ),
        OnboardingPage(
            imageName: "HomeWidgetReview",
            icon: "rectangle.on.rectangle.angled",
            headline: "Use Flashcards",
            description: "Create or select flashcards to reinforce memory with spaced repetition.",
            features: ["Spaced Review", "Self-Check", "Due Today"]
        ),
        OnboardingPage(
            imageName: "HomeWidgetGoals",
            icon: "graduationcap.fill",
            headline: "Start Learning",
            description: "Begin with a topic of interest and track progress every week.",
            features: ["Weekly Goals", "Quizzes", "Achievements"]
        )
    ]

    var body: some View {
        ZStack {
            PatternBackground()

            VStack(spacing: 0) {
                onboardingHeader
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page, pageIndex: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .background(Color.clear)
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                pageIndicator
                    .padding(.bottom, 20)

                PrimaryButton(title: currentPage == pages.count - 1 ? "Get Started" : "Next") {
                    if currentPage < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    } else {
                        HapticManager.mediumImpact()
                        SoundManager.playSuccess()
                        store.completeOnboarding()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .appScreenStyle()
    }

    private var onboardingHeader: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(AppDesign.Gradients.primaryHorizontal)
                .frame(width: 4, height: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text("Welcome")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                Text("Step \(currentPage + 1) of \(pages.count)")
                    .font(.headline)
                    .foregroundStyle(AppDesign.Gradients.title)
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color("AppTextSecondary").opacity(0.2), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: CGFloat(currentPage + 1) / CGFloat(pages.count))
                    .stroke(AppDesign.Gradients.ring, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(currentPage + 1)")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .frame(width: 36, height: 36)
        }
        .padding(.vertical, 8)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? AnyShapeStyle(AppDesign.Gradients.primaryHorizontal)
                            : AnyShapeStyle(Color("AppTextSecondary").opacity(0.25))
                    )
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
    }
}

// MARK: - Page Model

private struct OnboardingPage {
    let imageName: String
    let icon: String
    let headline: String
    let description: String
    let features: [String]
}

// MARK: - Page View

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 8)

            heroCard
                .padding(.horizontal, 24)
                .scaleEffect(appeared ? 1 : 0.94)
                .opacity(appeared ? 1 : 0)

            AppCard(accentBorder: true, elevated: true) {
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        IconBadge(systemName: page.icon, size: 40)
                        Text(page.headline)
                            .font(.title2.bold())
                            .foregroundStyle(AppDesign.Gradients.title)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Text(page.description)
                        .font(.body)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        ForEach(page.features, id: \.self) { feature in
                            Text(feature)
                                .font(.caption2.bold())
                                .foregroundStyle(Color("AppAccent"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppDesign.Gradients.accentTint)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color("AppAccent").opacity(0.25), lineWidth: 0.5)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 24)
            .offset(y: appeared ? 0 : 16)
            .opacity(appeared ? 1 : 0)

            Spacer()
        }
        .id(pageIndex)
        .onAppear {
            appeared = false
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                appeared = true
            }
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            Image(page.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 210)
                .clipped()

            LinearGradient(
                colors: [.clear, Color("AppBackground").opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )

            HStack(spacing: 8) {
                Image(systemName: page.icon)
                    .font(.caption.bold())
                Text("Feature Preview")
                    .font(.caption.bold())
            }
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(AppDesign.Gradients.primaryHorizontal)
                    .overlay {
                        Capsule()
                            .fill(AppDesign.Gradients.surfaceHighlight)
                    }
            }
            .appShadow(.soft)
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .appCardChrome(cornerRadius: 22, accentBorder: true, elevation: .elevated)
    }
}
