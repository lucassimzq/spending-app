import SwiftUI

/// A vertical line with a ring on it, from the timeline. Also the app's mark.
struct TimelineGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) * 0.36
        let center = CGPoint(x: rect.midX, y: rect.midY - rect.height * 0.06)
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: center.y - radius))
        path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        path.move(to: CGPoint(x: rect.midX, y: center.y + radius))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

/// The app's mark: the timeline glyph in white on a tangerine square. Used in widgets.
struct AppMark: View {
    var size: CGFloat = 22

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
            .fill(Theme.accentFill)
            .frame(width: size, height: size)
            .overlay {
                TimelineGlyph()
                    .stroke(.white, style: StrokeStyle(lineWidth: max(size * 0.09, 1.5), lineCap: .round))
                    .frame(width: size * 0.3, height: size * 0.64)
            }
            .accessibilityHidden(true)
    }
}
