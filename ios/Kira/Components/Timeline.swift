import SwiftUI
import KiraCore

/// Sizes shared by every timeline so the rail lines up across screens.
enum TimelineMetrics {
    /// Width of the rail column; the dots sit in its middle.
    static let railWidth: CGFloat = 32
    /// Where the cards start, measured from the rail column's left edge.
    static let contentInset: CGFloat = 40
    /// More than this between two entries draws the rail dashed: a quiet stretch of the day.
    static let quietGap: TimeInterval = 3 * 3600
}

enum RailLine {
    case solid, dashed

    /// Solid between nearby entries, dashed across a quiet gap.
    static func between(_ later: Date, _ earlier: Date) -> RailLine {
        later.timeIntervalSince(earlier) > TimelineMetrics.quietGap ? .dashed : .solid
    }
}

enum TimelineDot {
    /// The tangerine "Now" dot.
    case now
    /// An entry that isn't saved yet.
    case new
    /// A saved entry.
    case hollow
    /// A saved entry shown in compact form.
    case small
    /// No dot: the rail just passes the row (a question or a day label).
    case none
}

struct VerticalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

private struct RailSegment: View {
    let line: RailLine?

    var body: some View {
        if let line {
            VerticalLine()
                .stroke(Theme.rail, style: StrokeStyle(lineWidth: 2, lineCap: .butt, dash: line == .dashed ? [4, 5] : []))
                .frame(width: 2)
        } else {
            Color.clear.frame(width: 2)
        }
    }
}

private struct TimelineDotView: View {
    let style: TimelineDot

    var body: some View {
        switch style {
        case .now:
            Circle().fill(Theme.accent).frame(width: 15, height: 15)
        case .new:
            Circle().fill(Theme.accent).frame(width: 13, height: 13)
        case .hollow:
            Circle()
                .strokeBorder(Theme.dot, lineWidth: 2.5)
                .background { Circle().fill(Theme.background) }
                .frame(width: 14, height: 14)
        case .small:
            Circle().fill(Theme.dot).frame(width: 9, height: 9)
        case .none:
            Color.clear.frame(width: 1, height: 1)
        }
    }
}

/// One row of a timeline: the rail and its dot on the left, the content on the right.
/// The rail is drawn behind the whole row, so consecutive rows join into one line.
struct TimelineRow<Content: View>: View {
    var dot: TimelineDot
    var above: RailLine?
    var below: RailLine?
    var spacing: CGFloat = 6
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, spacing)
            .padding(.leading, TimelineMetrics.contentInset)
            .background(alignment: .leading) {
                VStack(spacing: 0) {
                    RailSegment(line: above).frame(maxHeight: .infinity)
                    RailSegment(line: below).frame(maxHeight: .infinity)
                }
                .frame(width: TimelineMetrics.railWidth)
                .overlay { TimelineDotView(style: dot) }
            }
    }
}

/// "Now · 7:45 PM", at the top of today's timeline.
struct NowLabel: View {
    let now: Date

    var body: some View {
        Text("Now · \(KiraFormat.time(now))")
            .figtree(17, weight: 650)
            .foregroundStyle(Theme.accentDeep)
            .padding(.vertical, 4)
            .accessibilityLabel("Now, \(KiraFormat.time(now))")
    }
}

/// An entry as a card: icon tile, title, "Food · 7:42 PM", amount and ›.
struct EntryCard: View {
    let title: String
    let subtitle: String
    var tag: String?
    let amount: Sen
    let isIncome: Bool
    let category: EntryCategory
    var isNew = false
    var isTransfer = false
    var showsChevron = true

    var body: some View {
        HStack(spacing: 14) {
            CategoryTile(category: category, size: 50, isTransfer: isTransfer)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .figtree(18, weight: 550)
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(subtitle)
                        .figtree(15)
                        .foregroundStyle(Theme.secondary)
                        .lineLimit(1)
                    if let tag {
                        InfoTag(text: tag)
                    }
                }
            }
            Spacer(minLength: 8)
            AmountLabel(amount: amount, isIncome: isIncome, strikethrough: isTransfer)
            if showsChevron { Chevron() }
        }
        .padding(14)
        .background(Theme.card, in: .rect(cornerRadius: 22))
        .overlay {
            if isNew {
                RoundedRectangle(cornerRadius: 22).strokeBorder(Theme.accent, lineWidth: 2)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

extension EntryCard {
    init(entry: LedgerEntry, calendar: Calendar = .current) {
        self.init(
            title: entry.title,
            subtitle: "\(entry.category.name) · \(KiraFormat.time(entry.date, calendar: calendar))",
            amount: entry.amount,
            isIncome: entry.isIncome,
            category: entry.category
        )
    }
}

/// A day of saved entries on the rail, newest first, with the Now marker on top for today.
struct DayTimeline: View {
    let entries: [LedgerEntry]
    var now: Date?
    let onSelect: (LedgerEntry) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let now {
                TimelineRow(dot: .now, above: nil, below: entries.first.map { RailLine.between(now, $0.date) }) {
                    NowLabel(now: now)
                }
                if entries.isEmpty {
                    Text("Nothing logged yet today.")
                        .figtree(16)
                        .foregroundStyle(Theme.secondary)
                        .padding(.leading, TimelineMetrics.contentInset)
                        .padding(.top, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            ForEach(Array(entries.enumerated()), id: \.element.uuid) { index, entry in
                TimelineRow(dot: .hollow, above: lineAbove(index), below: lineBelow(index)) {
                    Button { onSelect(entry) } label: {
                        EntryCard(entry: entry)
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
    }

    private func lineAbove(_ index: Int) -> RailLine? {
        if index == 0 {
            guard let now else { return nil }
            return RailLine.between(now, entries[0].date)
        }
        return RailLine.between(entries[index - 1].date, entries[index].date)
    }

    private func lineBelow(_ index: Int) -> RailLine? {
        guard index + 1 < entries.count else { return nil }
        return RailLine.between(entries[index].date, entries[index + 1].date)
    }
}

/// Saved entries as rows in one card, separated by lines (Month's category page and Search).
struct EntryList: View {
    let entries: [LedgerEntry]
    var subtitle: (LedgerEntry) -> String
    var highlight: String = ""
    let onSelect: (LedgerEntry) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(entries.enumerated()), id: \.element.uuid) { index, entry in
                Button { onSelect(entry) } label: {
                    HStack(spacing: 14) {
                        CategoryTile(category: entry.category, size: 46)
                        VStack(alignment: .leading, spacing: 3) {
                            HighlightedTitle(title: entry.title, highlight: highlight)
                            Text(subtitle(entry))
                                .figtree(15)
                                .foregroundStyle(Theme.secondary)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 8)
                        AmountLabel(amount: entry.amount, isIncome: entry.isIncome)
                        Chevron()
                    }
                    .padding(.vertical, 12)
                    .contentShape(.rect)
                }
                .buttonStyle(PressableStyle())
                .overlay(alignment: .bottom) {
                    if index < entries.count - 1 {
                        Rectangle()
                            .fill(Theme.separator)
                            .frame(height: 1)
                            .padding(.leading, 60)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(Theme.card, in: .rect(cornerRadius: Theme.cardRadius))
    }
}

/// A title with the part that matched the search in bold.
struct HighlightedTitle: View {
    let title: String
    var highlight: String

    var body: some View {
        styledTitle
            .figtree(18, weight: 450)
            .foregroundStyle(Theme.ink)
            .lineLimit(1)
    }

    private var styledTitle: Text {
        let needle = highlight.trimmingCharacters(in: .whitespaces)
        guard !needle.isEmpty, let range = title.range(of: needle, options: .caseInsensitive) else {
            return Text(verbatim: title)
        }
        let before = String(title[..<range.lowerBound])
        let match = Text(verbatim: String(title[range])).font(Font.figtree(18, weight: 700))
        let after = String(title[range.upperBound...])
        return Text("\(before)\(match)\(after)")
    }
}
