import SwiftData
import SwiftUI
import KiraCore

/// Search by typing or asking ("grab", "food last month"). The answer on top is worked out from the results,
/// chips narrow them down, and the field lives in the tab bar at the bottom.
struct SearchScreen: View {
    private enum Filter: Hashable {
        case all, thisMonth, category(EntryCategory), overTwenty
    }

    @Environment(AppModel.self) private var model
    @Query(sort: \LedgerEntry.date, order: .reverse) private var entries: [LedgerEntry]
    @State private var filter: Filter = .all

    var body: some View {
        let now = Date()
        let calendar = Calendar.current
        let query = SearchQuery(model.searchText)
        let matches = query.isEmpty ? [] : entries.filter { query.matches($0.item, now: now, calendar: calendar) }
        let filtered = matches.filter { passes($0, now: now, calendar: calendar) }

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ScreenTitle(title: "Search", subtitle: "Type it or ask it")
                        .padding(.bottom, 22)
                    if query.isEmpty {
                        suggestions
                    } else if matches.isEmpty {
                        Text("Nothing matches “\(model.searchText.trimmingCharacters(in: .whitespaces))”.")
                            .figtree(17)
                            .foregroundStyle(Theme.secondary)
                            .padding(.horizontal, 4)
                    } else {
                        if let answer = answer(for: query, matches: filtered, now: now, calendar: calendar) {
                            AITip(text: answer, detail: "Worked out from your \(filtered.count == 1 ? "entry" : "\(filtered.count) entries") below")
                                .padding(.bottom, 16)
                        }
                        filterChips(for: matches)
                            .padding(.bottom, 18)
                        SectionHeader(
                            title: filtered.count == 1 ? "1 result" : "\(filtered.count) results",
                            trailing: Money.format(filtered.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }, currency: true)
                        )
                        .padding(.bottom, 10)
                        if !filtered.isEmpty {
                            EntryList(
                                entries: Array(filtered.prefix(200)),
                                subtitle: { "\(dayText($0.date, now: now, calendar: calendar)) · \(KiraFormat.time($0.date, calendar: calendar))" },
                                highlight: query.term
                            ) { model.sheet = .edit($0.uuid) }
                        }
                    }
                }
                .padding(.horizontal, Theme.gutter)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.background)
        }
        .onChange(of: model.searchText) { _, _ in filter = .all }
    }

    // MARK: Parts

    private var suggestions: some View {
        let regulars = Regulars.top(from: entries.prefix(400).map(\.item), limit: 4)
        let ideas = regulars.map(\.title) + ["food last month", "this month"]
        return VStack(alignment: .leading, spacing: 12) {
            Text("Try")
                .figtree(16, weight: 500)
                .foregroundStyle(Theme.secondary)
                .padding(.horizontal, 4)
            FlowLayout(spacing: 10) {
                ForEach(ideas, id: \.self) { idea in
                    ChoiceChip(title: idea, isSelected: false) { model.searchText = idea }
                }
            }
        }
    }

    private func filterChips(for matches: [LedgerEntry]) -> some View {
        let categories = Array(Set(matches.map(\.category))).filter { $0 != .moneyIn }.sorted { $0.name < $1.name }
        return ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ChoiceChip(title: "All", isSelected: filter == .all) { filter = .all }
                ChoiceChip(title: "This month", isSelected: filter == .thisMonth) { toggle(.thisMonth) }
                ForEach(categories) { category in
                    ChoiceChip(title: category.name, isSelected: filter == .category(category)) { toggle(.category(category)) }
                }
                ChoiceChip(title: "Over RM 20", isSelected: filter == .overTwenty) { toggle(.overTwenty) }
            }
            .padding(.horizontal, Theme.gutter)
            .padding(.vertical, 6)
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, -Theme.gutter)
    }

    // MARK: Logic

    private func toggle(_ newFilter: Filter) {
        withAnimation(.snappy) { filter = filter == newFilter ? .all : newFilter }
    }

    private func passes(_ entry: LedgerEntry, now: Date, calendar: Calendar) -> Bool {
        switch filter {
        case .all:
            return true
        case .thisMonth:
            return calendar.isDate(entry.date, equalTo: now, toGranularity: .month)
        case .category(let category):
            return entry.category == category
        case .overTwenty:
            return entry.amount > 2_000
        }
    }

    private func answer(for query: SearchQuery, matches: [LedgerEntry], now: Date, calendar: Calendar) -> String? {
        let items = matches.map(\.item)
        var period = query.periodPhrase(for: items, now: now, calendar: calendar)
        if filter == .thisMonth { period = "this month" }
        return SearchAnswer.sentence(for: query.displayText, matches: items, period: period)
    }

    private func dayText(_ date: Date, now: Date, calendar: Calendar) -> String {
        let title = KiraFormat.dayTitle(date, now: now, calendar: calendar)
        return title == "Today" || title == "Yesterday" ? title : KiraFormat.shortDate(date, calendar: calendar)
    }
}
