import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack(alignment: .top) {
            PatternBackground()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .home: HomeView(selectedTab: $selectedTab)
                    case .explorer: ConceptExplorerView()
                    case .study: StudyHubView()
                    case .achievements: AchievementsView()
                    case .settings: SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)

                CustomTabBar(selectedTab: $selectedTab, dueCount: store.cardsDueToday().count)
            }

            if let achievement = store.pendingAchievement {
                AchievementBannerView(achievement: achievement) {
                    store.dismissAchievementBanner()
                }
                .padding(.top, 8)
                .zIndex(1)
            }
        }
        .appScreenStyle()
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    var dueCount: Int = 0

    var body: some View {
        HStack(spacing: 6) {
            ForEach(MainTab.allCases) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    badge: tab == .home ? dueCount : 0
                ) {
                    HapticManager.lightTap()
                    withAnimation(.easeInOut(duration: 0.3)) { selectedTab = tab }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: AppDesign.Radius.chip, style: .continuous)
                .fill(AppDesign.Gradients.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: AppDesign.Radius.chip, style: .continuous)
                        .fill(AppDesign.Gradients.surfaceHighlight)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: AppDesign.Radius.chip, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.10), Color("AppTextSecondary").opacity(0.14)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .appShadow(.elevated)
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }
}

private struct TabBarItem: View {
    let tab: MainTab
    let isSelected: Bool
    let badge: Int
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    if badge > 0 {
                        Circle()
                            .fill(Color("AppAccent"))
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: -4)
                    }
                }
                Text(tab.title)
                    .font(.caption2.weight(isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        isSelected
                            ? AnyShapeStyle(AppDesign.Gradients.primary)
                            : AnyShapeStyle(Color.clear)
                    )
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppDesign.Gradients.surfaceHighlight)
                        }
                    }
            )
            .scaleEffect(isPressed ? 0.94 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { isPressed = false } }
        )
    }
}
