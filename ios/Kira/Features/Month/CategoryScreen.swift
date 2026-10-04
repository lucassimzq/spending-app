import SwiftData
import SwiftUI
import KiraCore

/// One category for one month: the total, the same days of last month, and every entry by day.
struct CategoryScreen: View {
    let category: EntryCategory
    let month: Date
    @Environment(AppModel.self) private var model
    @Query(sort: \LedgerEntry.date, order: .reverse) private var entries: [LedgerEntry]

    var body: some View {
        let calendar = Calendar.current
        let now = Date()
        let interval = calendar.dateInterval(of: .month, for: month) ?? DateInterval(start: month, duration: 1)
        let matching = entries.filter { $0.category == category && $0.date >= interval.start && $0.date < interval.end }
        let comparison = CategoryComparison.make(category: category, items: entries.map(\.item), month: month, now: now, calendar: calendar)
        let days = groupedByDay(matching, calendar: calendar)
        let monthName = KiraFormat.monthName(interval.start, calendar: calendar)

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenTitle(
                    title: category.name,
                    subtitle: "\(monthName) · \(matching.count == 1 ? "1 entry" : "\(matching.count) entries")"
                )
                .padding(.bottom, 22)

                comparisonCard(total: matching.reduce(0) { $0 + $1.amount }, comparison: comparison, monthName: monthName)
                    .padding(.bottom, 26)

                ForEach(days, id: \.day) { group in
                    SectionHeader(
                        title: KiraFormat.dayTitle(group.day, now: now, calendar: calendar),
                        trailing: Money.format(group.entries.reduce(0) { $0 + $1.amount }, currency: true)
                    )
                    .padding(.bottom, 10)
                    EntryList(entries: group.entries, subtitle: { KiraFormat.time($0.date, calendar: calendar) }) {
                        model.sheet = .edit($0.uuid)
                    }
                    .padding(.bottom, 22)
                }
            }
            .padding(.horizontal, Theme.gutter)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Theme.background)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        model.searchText = category.name.lowercased()
                        model.select(.search)
                    } label: {
                        Label("Search \(category.name)", systemImage: "magnifyingglass")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
                .accessibilityLabel("More")
            }
        }
    }

    private func comparisonCard(total: Sen, comparison: CategoryComparison, monthName: String) -> some View {
        let largest = Double(max(comparison.thisPeriod, comparison.lastPeriod, 1))
        return VStack(alignment: .leading, spacing: 14) {
            LabeledMoney(label: "Spent on \(category.name.lowercased())", sen: total, size: 34)
            if comparison.lastPeriod > 0 {
                VStack(spacing: 12) {
                    comparisonRow(monthName, amount: comparison.thisPeriod, fraction: Double(comparison.thisPeriod) / largest, color: Theme.accent)
                    comparisonRow(comparison.lastMonthName, amount: comparison.lastPeriod, fraction: Double(comparison.lastPeriod) / largest, color: Theme.dot.opacity(0.6))
                }
                HStack(spacing: 8) {
                    Image(systemName: comparison.difference <= 0 ? "chart.line.downtrend.xyaxis" : "chart.line.uptrend.xyaxis")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.accentDeep)
                        .accessibilityHidden(true)
                    Text(comparison.sentence)
                        .figtree(16, weight: 600)
                        .foregroundStyle(Theme.ink)
                }
            }
        }
        .card()
    }

    private func comparisonRow(_ label: String, amount: Sen, fraction: Double, color: Color) -> some View {
        HStack(spacing: 14) {
            Text(label)
                .figtree(16)
                .foregroundStyle(Theme.secondary)
                .frame(width: 96, alignment: .leading)
            ProgressBar(value: fraction, color: color, height: 10)
            Text(Money.format(amount))
                .figtree(16, weight: 550, digits: true)
                .foregroundStyle(Theme.ink)
                .frame(minWidth: 70, alignment: .trailing)
        }
        .accessibilityElement(children: .combine)
    }

    private func groupedByDay(_ entries: [LedgerEntry], calendar: Calendar) -> [(day: Date, entries: [LedgerEntry])] {
        let groups = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
        return groups
            .map { (day: $0.key, entries: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.day > $1.day }
    }
}
