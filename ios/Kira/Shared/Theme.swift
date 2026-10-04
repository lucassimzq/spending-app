import SwiftUI

/// The Round 6 palette: a neutral soft white, one light tangerine accent, and green only for money in.
/// Every text colour here passes WCAG AA on the backgrounds it's used on.
enum Theme {
    // Accent
    /// Fills only (Add tab, ✓ buttons, selected chips, the Now dot, progress bars), always with ink text on top.
    static let accent = Color(hex: 0xFFA552)
    /// Small tangerine text and icons.
    static let accentDeep = Color(hex: 0xA84A0C)
    /// Behind AI tips, guesses and "New" tags.
    static let accentTint = Color(hex: 0xFFF1E4)
    static let accentFill = LinearGradient(
        colors: [Color(hex: 0xFFBA7A), Color(hex: 0xFF9B45)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Neutrals
    static let background = Color(hex: 0xF5F4F1)
    static let card = Color.white
    static let ink = Color(hex: 0x1F1A17)
    static let secondary = Color(hex: 0x655C54)
    static let separator = Color(hex: 0xE8E6E2)
    static let tile = Color(hex: 0xF1EFEC)
    static let track = Color(hex: 0xE9E6E1)

    // Data
    static let green = Color(hex: 0x1B6E30)
    static let greenTint = Color(hex: 0xE6F4E8)
    static let red = Color(hex: 0xC4122E)

    // Timeline
    static let rail = Color(hex: 0xDAD7D2)
    static let dot = Color(hex: 0xACA59E)
    static let chevron = Color(hex: 0xC4BFB8)

    // Charts
    static let bar = Color(hex: 0xD9711A)
    static let barSoft = Color(hex: 0xFFD3AA)

    static let cardRadius: CGFloat = 26
    static let gutter: CGFloat = 16
}

extension Color {
    /// `Color(hex: 0xFFA552)`
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
