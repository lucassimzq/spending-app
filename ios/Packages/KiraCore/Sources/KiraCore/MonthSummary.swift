import Foundation

public struct CategoryTotal: Equatable, Sendable, Identifiable {
    public var id: EntryCategory { category }
    public let category: EntryCategory
    public let total: Sen
    public let count: Int

    public init(category: EntryCategory, total: Sen, count: Int) {
        self.category = category
        self.total = total
        self.count = count
    }
}

/// Everything the Today and Month screens show about one calendar month.
public struct MonthSummary: Equatable, Sendable {
    public let start: Date
    public let daysInMonth: Int
    /// Days of the month that have started (today included). All of them for a past month, 0 for a future one.
    public let elapsedDays: Int
    public let spent: Sen
    public let cameIn: Sen
    /// Spending per day; index 0 is the 1st.
    public let dailySpent: [Sen]
    /// Spending only, largest first.
    public let categories: [CategoryTotal]

    public var left: Sen { cameIn - spent }
    public var daysLeft: Int { max(daysInMonth - elapsedDays, 0) }
    /// Share of the money that came in which has gone out, e.g. 0.41.
    public var spentShare: Double? { cameIn > 0 ? Double(spent) / Double(cameIn) : nil }
    /// Share of the month that has gone, e.g. 0.6 on the 18th of a 30-day month.
    public var elapsedShare: Double { Double(elapsedDays) / Double(max(daysInMonth, 1)) }
    /// What's left, spread over the remaining days.
    public var perDayLeft: Sen? { daysLeft > 0 && left > 0 ? left / daysLeft : nil }

    public func total(for category: EntryCategory) -> Sen {
        categories.first { $0.category == category }?.total ?? 0
    }

    /// Daily average leaving rent out, because one big payment hides the everyday pace.
    public var averagePerDayWithoutRent: Sen {
        (spent - total(for: .rent)) / max(elapsedDays, 1)
    }

    public init(start: Date, daysInMonth: Int, elapsedDays: Int, spent: Sen, cameIn: Sen, dailySpent: [Sen], categories: [CategoryTotal]) {
        self.start = start
        self.daysInMonth = daysInMonth
        self.elapsedDays = elapsedDays
        self.spent = spent
        self.cameIn = cameIn
        self.dailySpent = dailySpent
        self.categories = categories
    }

    public static func make(items: [LedgerItem], month date: Date, now: Date = Date(), calendar: Calendar = .current) -> MonthSummary {
        let interval = calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: date, duration: 30 * 86_400)
        let days = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        let elapsed: Int
        if now >= interval.end {
            elapsed = days
        } else if now < interval.start {
            elapsed = 0
        } else {
            elapsed = calendar.component(.day, from: now)
        }

        var daily = Array(repeating: 0, count: days)
        var spent = 0
        var cameIn = 0
        var totals: [EntryCategory: (total: Sen, count: Int)] = [:]
        for item in items where item.date >= interval.start && item.date < interval.end {
            if item.isIncome {
                cameIn += item.amount
                continue
            }
            spent += item.amount
            let day = calendar.component(.day, from: item.date)
            if day >= 1 && day <= days { daily[day - 1] += item.amount }
            let previous = totals[item.category] ?? (0, 0)
            totals[item.category] = (previous.total + item.amount, previous.count + 1)
        }
        let categories = totals
            .map { CategoryTotal(category: $0.key, total: $0.value.total, count: $0.value.count) }
            .sorted { $0.total != $1.total ? $0.total > $1.total : $0.category.rawValue < $1.category.rawValue }
        return MonthSummary(start: interval.start, daysInMonth: days, elapsedDays: elapsed, spent: spent, cameIn: cameIn,
                            dailySpent: daily, categories: categories)
    }

    /// "Spending slower than the month: 41% of income gone, 60% of September gone."
    public func paceSentence(calendar: Calendar = .current) -> String {
        let month = KiraFormat.monthName(start, calendar: calendar)
        guard let share = spentShare else {
            return spent == 0 ? "Nothing logged yet in \(month)." : "Nothing has come in yet in \(month), so there is nothing to measure spending against."
        }
        let spentPercent = Int((share * 100).rounded())
        let monthPercent = Int((elapsedShare * 100).rounded())
        if share <= elapsedShare {
            return "Spending slower than the month: \(spentPercent)% of income gone, \(monthPercent)% of \(month) gone."
        }
        return "Spending faster than the month: \(spentPercent)% of income gone, only \(monthPercent)% of \(month) gone."
    }
}

/// One category this month against the same days of last month.
public struct CategoryComparison: Equatable, Sendable {
    public let thisPeriod: Sen
    public let lastPeriod: Sen
    public let lastMonthName: String
    public var difference: Sen { thisPeriod - lastPeriod }

    /// "RM 61 less than August by this date"
    public var sentence: String {
        if lastPeriod == 0 { return "Nothing in \(lastMonthName) to compare with" }
        if difference == 0 { return "The same as \(lastMonthName) by this date" }
        let amount = Money.roundedRinggit(abs(difference))
        return difference < 0 ? "\(amount) less than \(lastMonthName) by this date" : "\(amount) more than \(lastMonthName) by this date"
    }

    public static func make(category: EntryCategory, items: [LedgerItem], month date: Date, now: Date = Date(), calendar: Calendar = .current) -> CategoryComparison {
        let summary = MonthSummary.make(items: items, month: date, now: now, calendar: calendar)
        let throughDay = max(summary.elapsedDays, 1)
        let thisPeriod = items.filter {
            !$0.isIncome && $0.category == category && $0.date >= summary.start
                && calendar.component(.day, from: $0.date) <= throughDay && $0.date < (calendar.date(byAdding: .month, value: 1, to: summary.start) ?? now)
        }.reduce(0) { $0 + $1.amount }

        let lastStart = calendar.date(byAdding: .month, value: -1, to: summary.start) ?? summary.start
        let lastPeriod = items.filter {
            !$0.isIncome && $0.category == category && $0.date >= lastStart && $0.date < summary.start
                && calendar.component(.day, from: $0.date) <= throughDay
        }.reduce(0) { $0 + $1.amount }
        return CategoryComparison(thisPeriod: thisPeriod, lastPeriod: lastPeriod, lastMonthName: KiraFormat.monthName(lastStart, calendar: calendar))
    }
}
