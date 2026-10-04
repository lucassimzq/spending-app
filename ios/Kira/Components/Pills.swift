import SwiftUI
import KiraCore

/// A small square-cornered label that describes an entry: "New", "1:00 PM · guessed". Not tappable.
struct InfoTag: View {
    let text: String

    var body: some View {
        Text(text)
            .figtree(14, weight: 650)
            .foregroundStyle(Theme.accentDeep)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Theme.accentTint, in: .rect(cornerRadius: 7))
    }
}

/// A round chip that picks or filters in one tap. The selected one is filled with the accent.
struct ChoiceChip: View {
    let title: String
    var systemImage: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .medium))
                        .accessibilityHidden(true)
                }
                Text(title)
                    .figtree(18, weight: isSelected ? 650 : 500)
            }
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 20)
            .frame(minHeight: 50)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Theme.accentFill)
                        .shadow(color: Theme.accent.opacity(0.3), radius: 8, y: 3)
                }
            }
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .glassEffect(isSelected ? .identity : .regular.interactive(), in: .capsule)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// "+ Teh tarik  2.80": logs a regular again in one tap.
struct LogAgainChip: View {
    let regular: Regular
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.accentDeep)
                Text(regular.title)
                    .figtree(18, weight: 500)
                    .lineLimit(1)
                Text(Money.format(regular.amount))
                    .figtree(18, weight: 700, digits: true)
            }
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 18)
            .frame(minHeight: 50)
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .capsule)
        .accessibilityLabel("Log \(regular.title) again, \(Money.format(regular.amount, currency: true))")
    }
}

/// One entry the app heard or read, as a glass chip: the icon, the title and the amount.
struct DraftChip: View {
    let draft: EntryDraft

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: draft.category.symbol)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(draft.isIncome ? Theme.green : Theme.ink)
            Text(draft.title)
                .figtree(17, weight: 500)
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
            Text(draft.isIncome ? Money.format(draft.amount, signed: true) : Money.format(draft.amount))
                .figtree(17, weight: 700, digits: true)
                .foregroundStyle(draft.isIncome ? Theme.green : Theme.ink)
        }
        .padding(.horizontal, 18)
        .frame(minHeight: 48)
        .glassEffect(.regular, in: .capsule)
        .accessibilityElement(children: .combine)
    }
}

/// Lays chips out in rows, wrapping to the next row when one is full.
struct FlowLayout: Layout {
    var spacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var widest: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > width {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            widest = max(widest, x - spacing)
        }
        return CGSize(width: proposal.width ?? widest, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
