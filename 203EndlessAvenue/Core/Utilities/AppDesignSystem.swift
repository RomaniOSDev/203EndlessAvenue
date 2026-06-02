import SwiftUI

// MARK: - Tokens (static — no per-frame allocation)

enum AppDesign {
    enum Radius {
        static let card: CGFloat = 16
        static let button: CGFloat = 14
        static let chip: CGFloat = 20
    }

    enum Elevation {
        case soft, card, elevated, glow

        var color: Color {
            switch self {
            case .soft: return .black.opacity(0.10)
            case .card: return .black.opacity(0.18)
            case .elevated: return .black.opacity(0.26)
            case .glow: return Color("AppPrimary").opacity(0.32)
            }
        }

        var radius: CGFloat {
            switch self {
            case .soft: return 4
            case .card: return 8
            case .elevated: return 14
            case .glow: return 10
            }
        }

        var y: CGFloat {
            switch self {
            case .soft: return 2
            case .card: return 4
            case .elevated: return 6
            case .glow: return 4
            }
        }
    }

    enum Gradients {
        static let primary = LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let primaryHorizontal = LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent")],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let background = LinearGradient(
            colors: [Color("AppBackground"), Color("AppSurface")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let surface = LinearGradient(
            colors: [
                Color("AppSurface").opacity(1),
                Color("AppSurface").opacity(0.82)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let surfaceHighlight = LinearGradient(
            colors: [
                Color.white.opacity(0.10),
                Color.white.opacity(0)
            ],
            startPoint: .top,
            endPoint: .center
        )

        static let accentTint = LinearGradient(
            colors: [Color("AppAccent").opacity(0.22), Color("AppPrimary").opacity(0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let title = LinearGradient(
            colors: [Color("AppTextPrimary"), Color("AppTextPrimary").opacity(0.82)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let ring = AngularGradient(
            colors: [Color("AppPrimary"), Color("AppAccent"), Color("AppPrimary")],
            center: .center
        )
    }
}

// MARK: - Reusable chrome (single compositingGroup + single shadow)

struct AppCardBackground: View {
    var cornerRadius: CGFloat = AppDesign.Radius.card
    var accentBorder: Bool = false
    var isHighlighted: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(backgroundGradient)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppDesign.Gradients.surfaceHighlight)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderGradient, lineWidth: accentBorder ? 1.5 : 1)
            }
    }

    private var backgroundGradient: LinearGradient {
        if isHighlighted {
            return LinearGradient(
                colors: [Color("AppAccent").opacity(0.18), Color("AppSurface").opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return AppDesign.Gradients.surface
    }

    private var borderGradient: LinearGradient {
        if accentBorder {
            return LinearGradient(
                colors: [Color("AppAccent").opacity(0.55), Color("AppPrimary").opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color.white.opacity(0.08), Color("AppTextSecondary").opacity(0.12)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    /// One rasterized shadow — use on containers, not on every list row modifier chain.
    func appShadow(_ elevation: AppDesign.Elevation = .card) -> some View {
        compositingGroup()
            .shadow(color: elevation.color, radius: elevation.radius, y: elevation.y)
    }

    func appCardChrome(
        cornerRadius: CGFloat = AppDesign.Radius.card,
        accentBorder: Bool = false,
        isHighlighted: Bool = false,
        elevation: AppDesign.Elevation = .card
    ) -> some View {
        background {
            AppCardBackground(
                cornerRadius: cornerRadius,
                accentBorder: accentBorder,
                isHighlighted: isHighlighted
            )
        }
        .appShadow(elevation)
    }

    func appPrimaryButtonChrome(cornerRadius: CGFloat = AppDesign.Radius.button) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppDesign.Gradients.primaryHorizontal)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppDesign.Gradients.surfaceHighlight)
                }
        }
        .appShadow(.glow)
    }

    func appInsetFieldChrome(cornerRadius: CGFloat = 14) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppDesign.Gradients.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.07), Color("AppTextSecondary").opacity(0.14)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .appShadow(.soft)
    }
}
