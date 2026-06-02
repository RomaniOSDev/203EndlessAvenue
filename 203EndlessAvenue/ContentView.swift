import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore()

    init() {
        AppAppearance.configure()
    }

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .background(ClearHostingBackground())
        .environmentObject(store)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
