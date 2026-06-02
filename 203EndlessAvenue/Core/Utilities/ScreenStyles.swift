import SwiftUI

extension View {
    /// Makes scroll content transparent so PatternBackground shows through.
    func appScrollStyle() -> some View {
        scrollContentBackground(.hidden)
            .background(Color.clear)
    }

    /// Transparent container for screens with embedded PatternBackground.
    func appScreenStyle() -> some View {
        background(Color.clear)
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct AppScreenContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .appScreenStyle()
    }
}
