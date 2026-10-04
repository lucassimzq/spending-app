import Foundation

/// What was typed in the search box, read as a question: "grab", "food last month", "how much on coffee this month?".
/// The period and category words become filters and whatever is left is matched against titles.
public struct SearchQuery: Equatable, Sendable {
    public enum Period: Equatable, Sendable {
        case any, today, yesterday, thisMonth, lastMonth
    }

    /// Text to find in titles, lowercased. Empty when the query was only a period or a category.
    public let term: String
    public let category: EntryCategory?
    public let period: Period

    private static let periods: [(phrase: String, period: Period)] = [
        ("this month", .thisMonth), ("last month", .lastMonth), ("today", .today), ("yesterday", .yesterday),
    ]
    private static let categoryWords: [String: EntryCategory] = [
        "food": .food, "groceries": .groceries, "grocery": .groceries, "transport": .transport,
        "shopping": .shopping, "bills": .bills, "bill": .bills, "rent": .rent, "income": .moneyIn, "other": .other,
    ]
    private static let filler: Set<String> = [
        "how", "much", "many", "did", "do", "i", "we", "spend", "spent", "on", "for", "in", "at", "the", "my", "what",
        "was", "were", "is", "total", "show", "me", "find", "entries", "times",
    ]

    public init(_ text: String) {
        var lowered = " " + text.lowercased() + " "
        for mark in ["?", "!", ",", "."] { lowered = lowered.replacingOccurrences(of: mark, with: " ") }

        var period = Period.any
        for candidate in Self.periods where lowered.contains(" \(candidate.phrase) ") {
            period = candidate.period
            lowered = lowered.replacingOccurrences(of: " \(candidate.phrase) ", with: " ")
            break
        }
        let words = lowered.split(whereSeparator: { $0 == " " }).map(String.init).filter { !Self.filler.contains($0) }

        // One category word becomes a filter ("food"); with other words it narrows them ("food grab" → grab in food).
        var category: EntryCategory?
        var rest: [String] = []
        for word in words {
            if category == nil, let match = Self.categoryWords[word] {
                category = match
            } else {
                rest.append(word)
            }
        }
        self.term = rest.joined(separator: " ")
        self.category = category
        self.period = period
    }

    public var isEmpty: Bool { term.isEmpty && category == nil && period == .any }

    /// The dates the period covers, or nil for any time.
    public func interval(now: Date = Date(), calendar: Calendar = .current) -> DateInterval? {
        let today = calendar.startOfDay(for: now)
        switch period {
        case .any:
            return nil
        case .today:
            return calendar.dateInterval(of: .day, for: now)
        case .yesterday:
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return nil }
            return DateInterval(start: yesterday, end: today)
        case .thisMonth:
            return calendar.dateInterval(of: .month, for: now)
        case .lastMonth:
            guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return nil }
            return calendar.dateInterval(of: .month, for: lastMonth)
        }
    }

    public func matches(_ item: LedgerItem, now: Date = Date(), calendar: Calendar = .current) -> Bool {
        if let category, item.category != category { return false }
        if !term.isEmpty, !item.title.lowercased().contains(term) { return false }
        if let range = interval(now: now, calendar: calendar), item.date < range.start || item.date >= range.end {
            return false
        }
        return true
    }

    /// The words the answer uses for the query: the title text, or the category's name.
    public var displayText: String {
        if !term.isEmpty { return term }
        return category?.name.lowercased() ?? ""
    }

    /// How the answer names the time span: the period that was asked for, or the span the matches cover
    /// ("this month", "last month", "since August").
    public func periodPhrase(for matches: [LedgerItem], now: Date = Date(), calendar: Calendar = .current) -> String {
        switch period {
        case .today: return "today"
        case .yesterday: return "yesterday"
        case .thisMonth: return "this month"
        case .lastMonth: return "last month"
        case .any: break
        }
        let dates = matches.map(\.date)
        guard let earliest = dates.min(), let latest = dates.max() else { return "this month" }
        if let thisMonth = calendar.dateInterval(of: .month, for: now), earliest >= thisMonth.start {
            return "this month"
        }
        if let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now),
           let lastMonth = calendar.dateInterval(of: .month, for: lastMonthDate),
           earliest >= lastMonth.start, latest < lastMonth.end {
            return "last month"
        }
        var since = "since " + KiraFormat.monthName(earliest, calendar: calendar)
        if calendar.component(.year, from: earliest) != calendar.component(.year, from: now) {
            since += " \(calendar.component(.year, from: earliest))"
        }
        return since
    }
}
