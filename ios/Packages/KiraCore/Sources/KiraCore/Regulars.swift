import Foundation

/// Something you log often, offered as a one-tap "Log again" chip.
public struct Regular: Equatable, Hashable, Sendable, Identifiable {
    public var id: String { title.lowercased() }
    public let title: String
    public let amount: Sen
    public let category: EntryCategory
    /// How many times it was logged in the window that was looked at.
    public let count: Int

    public init(title: String, amount: Sen, category: EntryCategory, count: Int) {
        self.title = title
        self.amount = amount
        self.category = category
        self.count = count
    }
}

public enum Regulars {
    /// Spending logged at least twice in the last `days` days, most frequent first (the more recent wins a tie).
    /// Titles are grouped ignoring case. The amount offered is the one used most often, and the latest of those
    /// when several tie, so "Grab" offers your usual fare. Rent and money in are left out: they aren't everyday taps.
    public static func top(
        from items: [LedgerItem],
        now: Date = Date(),
        days: Int = 60,
        limit: Int = 6,
        calendar: Calendar = .current
    ) -> [Regular] {
        let since = calendar.date(byAdding: .day, value: -days, to: now) ?? now
        let recent = items.filter {
            !$0.isIncome && $0.category != .rent && $0.amount > 0 && $0.date >= since && $0.date <= now
        }
        let groups = Dictionary(grouping: recent) { $0.title.trimmingCharacters(in: .whitespaces).lowercased() }

        var found: [(regular: Regular, latest: Date)] = []
        for (key, group) in groups where !key.isEmpty && group.count >= 2 {
            let newestFirst = group.sorted { $0.date > $1.date }
            guard let latest = newestFirst.first else { continue }
            var uses: [Sen: Int] = [:]
            for item in group { uses[item.amount, default: 0] += 1 }
            let mostUses = uses.values.max() ?? 0
            let amount = newestFirst.first { uses[$0.amount] == mostUses }?.amount ?? latest.amount
            let regular = Regular(title: latest.title, amount: amount, category: latest.category, count: group.count)
            found.append((regular, latest.date))
        }
        let sorted = found.sorted {
            $0.regular.count != $1.regular.count ? $0.regular.count > $1.regular.count : $0.latest > $1.latest
        }
        return sorted.prefix(limit).map { $0.regular }
    }
}
