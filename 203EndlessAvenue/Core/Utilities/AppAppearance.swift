import SwiftUI
import UIKit

enum AppAppearance {
    static func configure() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundColor = .clear
        navAppearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        UITableView.appearance().backgroundColor = .clear
        UIScrollView.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear
    }
}

struct ClearHostingBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        ClearBackgroundView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    private final class ClearBackgroundView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            makeHostingLayersTransparent()
        }

        private func makeHostingLayersTransparent() {
            var view: UIView? = superview
            while let current = view {
                let typeName = String(describing: type(of: current))
                if typeName.contains("Hosting") {
                    current.backgroundColor = .clear
                }
                view = current.superview
            }
        }
    }
}
