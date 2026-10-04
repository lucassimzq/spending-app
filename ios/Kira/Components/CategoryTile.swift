import SwiftUI
import KiraCore

/// The rounded square with a category's icon. Money in gets the green tint.
struct CategoryTile: View {
    let category: EntryCategory
    var size: CGFloat = 50
    /// Wallet top-ups show a two-way arrow instead of their category.
    var isTransfer = false

    var body: some View {
        let isIncome = category == .moneyIn
        Image(systemName: isTransfer ? "arrow.left.arrow.right" : category.symbol)
            .font(.system(size: size * 0.38, weight: .medium))
            .foregroundStyle(isIncome ? Theme.green : Theme.ink)
            .frame(width: size, height: size)
            .background(isIncome ? Theme.greenTint : Theme.tile, in: .rect(cornerRadius: size * 0.28))
            .accessibilityHidden(true)
    }
}
