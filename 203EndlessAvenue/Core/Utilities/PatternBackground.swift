import SwiftUI

struct PatternBackground: View {
    var body: some View {
        ZStack {
            AppDesign.Gradients.background

            Canvas { context, size in
                let spacing: CGFloat = 40
                var path = Path()
                var x: CGFloat = spacing / 2
                while x < size.width {
                    var y: CGFloat = spacing / 2
                    while y < size.height {
                        path.addEllipse(in: CGRect(x: x, y: y, width: 1.5, height: 1.5))
                        y += spacing
                    }
                    x += spacing
                }
                context.fill(path, with: .color(Color("AppTextSecondary").opacity(0.14)))
            }
        }
        .drawingGroup(opaque: false)
        .ignoresSafeArea()
    }
}
