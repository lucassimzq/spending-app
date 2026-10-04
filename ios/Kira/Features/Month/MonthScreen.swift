import SwiftData
import SwiftUI
import KiraCore

/// The month: spent against what came in, a daily chart, how the pace compares with the calendar,
/// and where the money went. Categories open their own page.
struct MonthScreen: View {
    @Environment(AppModel.self) private var model
    @Query(sort: \LedgerEntry.date, order: .reverse) private var entries: [LedgerEntry]
    /// Any date inside the month being shown.
    @State private var month = Date()

    var body: some View {
        NavigationStack {
            TimelineView(.everyMinute) { context in
                content(now: context.date)
            }
            .background(Theme.background)
            .toolbar { toolbar }
            .navigationDestination(for: EntryCategory.self) { category in
                CategoryScreen(category: category, month: month)
            }
        }
    }

    private func content(now: Date) -> some View {
        let calendar = Calendar.current
        let items = entries.map(\.item)
        let summary = MonthSummary.make(items: items, month: month, now: now, calendar: calendar)
        let isCurrent = calendar.isDate(month, equalTo: now, toGranularity: .month)

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenTitle(title: KiraFormat.monthName(summary.start, calendar: calendar), subtitle: subtitle(summary, isCurrent: isCurrent, now: now))
                    .padding(.bottom, 6)
                spentCard(summary)
                DailySpendingCard(summary: summary, items: items, today: isCurrent ? calendar.component(.day, from: now) : nil)
                AITip(text: summary.paceSentence(calendar: calendar))
                if !summary.categories.isEmpty {
                    WhereItWentCard(summary: summary, items: items, month: month, now: now)
                }
            }
            .padding(.horizontal, Theme.gutter)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private func subtitle(_ summary: MonthSummary, isCurrent: Bool, now: Date) -> String {
        guard isCurrent else { return "\(summary.daysInMonth) days" }
        let range = KiraFormat.monthToDate(start: summary.start, through: now)
        let left = summary.daysLeft == 1 ? "1 day left" : "\(summary.daysLeft) days left"
        return "\(range) · \(left)"
    }

    private func spentCard(_ summary: MonthSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SpentAndCameIn(spent: summary.spent, cameIn: summary.cameIn)
            ProgressBar(value: summary.spentShare ?? 0)
            HStack {
                Text(shareText(summary))
                    .figtree(16, weight: 600)
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text(leftText(summary))
                    .figtree(16, digits: true)
                    .foregroundStyle(Theme.secondary)
            }
        }
        .card()
    }

    private func shareText(_ summary: MonthSummary) -> String {
        guard let share = summary.spentShare else { return "Nothing has come in yet" }
        return "\(Int((share * 100).rounded()))% of income spent"
    }

    private func leftText(_ summary: MonthSummary) -> String {
        summary.left >= 0
            ? "\(Money.format(summary.left, currency: true)) left"
            : "\(Money.format(-summary.left, currency: true)) over"
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu {
                ForEach(availableMonths, id: \.self) { start in
                    Button(monthTitle(start)) { month = start }
                }
            } label: {
                Image(systemName: "calendar")
            }
            .accessibilityLabel("Choose a month")
            ShareLink(item: shareSummary) {
                Image(systemName: "square.and.arrow.up")
            }
            .accessibilityLabel("Share this month")
        }
    }

    /// The start of every month with entries, newest first, plus this month.
    private var availableMonths: [Date] {
        let calendar = Calendar.current
        var starts = Set(entries.compactMap { calendar.dateInterval(of: .month, for: $0.date)?.start })
        if let current = calendar.dateInterval(of: .month, for: Date())?.start { starts.insert(current) }
        return starts.sorted(by: >)
    }

    private func monthTitle(_ start: Date) -> String {
        let calendar = Calendar.current
        let name = KiraFormat.monthName(start, calendar: calendar)
        let year = calendar.component(.year, from: start)
        return year == calendar.component(.year, from: Date()) ? name : "\(name) \(year)"
    }

    private var shareSummary: String {
        let summary = MonthSummary.make(items: entries.map(\.item), month: month)
        let name = KiraFormat.monthName(summary.start)
        return "\(name): \(Money.format(summary.spent, currency: true)) out, \(Money.format(summary.cameIn, currency: true)) in. \(summary.paceSentence())"
    }
}

/// Spending per day as bars, today in the deeper tangerine, the days to come as dots,
/// and a dashed line at the everyday average (rent left out).
private struct DailySpendingCard: View {
    let summary: MonthSummary
    let items: [LedgerItem]
    let today: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Daily spending")
                    .figtree(18, weight: 650)
                    .foregroundStyle(Theme.ink)
                Spacer(minLength: 8)
                if summary.elapsedDays > 0 {
                    Text("\(Money.roundedRinggit(summary.averagePerDayWithoutRent)) a day, without rent")
                        .figtree(15)
                        .foregroundStyle(Theme.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            DailyBars(
                daily: summary.dailySpent,
                elapsedDays: summary.elapsedDays,
                today: today,
                average: summary.averagePerDayWithoutRent,
                rentDays: rentDays
            )
        }
        .card()
    }

    private var rentDays: Set<Int> {
        let calendar = Calendar.current
        let end = calendar.date(byAdding: .month, value: 1, to: summary.start) ?? summary.start
        return Set(items
            .filter { $0.category == .rent && $0.date >= summary.start && $0.date < end }
            .map { calendar.component(.day, from: $0.date) })
    }
}

/// Each category with its total, a bar against the biggest, and how it compares with last month.
private struct WhereItWentCard: View {
    let summary: MonthSummary
    let items: [LedgerItem]
    let month: Date
    let now: Date

    var body: some View {
        let largest = summary.categories.first?.total ?? 1
        VStack(alignment: .leading, spacing: 4) {
            Text("Where it went")
                .figtree(18, weight: 650)
                .foregroundStyle(Theme.ink)
                .padding(.bottom, 8)
            ForEach(Array(summary.categories.enumerated()), id: \.element.id) { index, total in
                NavigationLink(value: total.category) {
                    HStack(spacing: 16) {
                        CategoryTile(category: total.category, size: 46)
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(total.category.name)
                                    .figtree(18, weight: 550)
                                    .foregroundStyle(Theme.ink)
                                Spacer(minLength: 8)
                                Text(Money.format(total.total))
                                    .figtree(18, weight: 550, digits: true)
                                    .foregroundStyle(Theme.ink)
                            }
                            ProgressBar(value: Double(total.total) / Double(max(largest, 1)), height: 6)
                            Text(detail(for: total))
                                .figtree(14)
                                .foregroundStyle(Theme.secondary)
                                .lineLimit(1)
                        }
                        Chevron()
                    }
                    .padding(.vertical, 10)
                    .contentShape(.rect)
                }
                .buttonStyle(PressableStyle())
                .overlay(alignment: .bottom) {
                    if index < summary.categories.count - 1 {
                        Rectangle().fill(Theme.separator).frame(height: 1).padding(.leading, 62)
                    }
                }
            }
        }
        .card()
    }

    private func detail(for total: CategoryTotal) -> String {
        let entries = total.count == 1 ? "1 entry" : "\(total.count) entries"
        let comparison = CategoryComparison.make(category: total.category, items: items, month: month, now: now)
        guard comparison.lastPeriod > 0, comparison.difference != 0 else { return entries }
        let amount = Money.roundedRinggit(abs(comparison.difference))
        let direction = comparison.difference < 0 ? "less" : "more"
        return "\(entries) · \(amount) \(direction) than \(comparison.lastMonthName)"
    }
}
