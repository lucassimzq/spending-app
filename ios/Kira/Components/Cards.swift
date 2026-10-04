import SwiftUI
import KiraCore

/// A white rounded card, the container for every section.
private struct CardBackground: ViewModifier {
    var padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: .rect(cornerRadius: Theme.cardRadius))
    }
}

extension View {
    func card(padding: CGFloat = 20) -> some View {
        modifier(CardBackground(padding: padding))
    }
}

/// The big Fraunces title at the top of a screen, with a line under it.
struct ScreenTitle: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .fraunces(44, weight: 650, wonky: true, relativeTo: .largeTitle, maximumScale: 1.3)
                .tracking(-0.6)
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(subtitle)
                    .figtree(17, relativeTo: .subheadline)
                    .foregroundStyle(Theme.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

/// A label above a group, with an optional total on the right: "Spent today      RM 46.10".
struct SectionHeader: View {
    let title: String
    var trailing: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .figtree(17, weight: 500)
                .foregroundStyle(Theme.secondary)
            Spacer(minLength: 12)
            if let trailing {
                Text(trailing)
                    .figtree(17, weight: 650, digits: true)
                    .foregroundStyle(Theme.ink)
            }
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

/// The › on rows and cards that open something.
struct Chevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Theme.chevron)
            .accessibilityHidden(true)
    }
}

/// Something the app worked out, on the tangerine tint.
struct AITip: View {
    let text: String
    var detail: String?

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "sparkle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.accentDeep)
                .padding(.top, 2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text(text)
                    .figtree(17, weight: 600)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if let detail {
                    Text(detail)
                        .figtree(14)
                        .foregroundStyle(Theme.secondary)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.accentTint, in: .rect(cornerRadius: 24))
        .accessibilityElement(children: .combine)
    }
}

/// Shrinks a little while pressed, for cards and rows that open something.
struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}

/// A thin progress bar: tangerine on a light track.
struct ProgressBar: View {
    /// 0...1
    let value: Double
    var color: Color = Theme.accent
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.track)
                Capsule()
                    .fill(color)
                    .frame(width: max(height, proxy.size.width * min(max(value, 0), 1)))
                    .opacity(value > 0 ? 1 : 0)
            }
        }
        .frame(height: height)
        .accessibilityHidden(true)
    }
}
