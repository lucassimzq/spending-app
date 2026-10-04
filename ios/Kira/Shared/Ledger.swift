import Foundation
import SwiftData
import WidgetKit
import KiraCore

/// Reads and summaries shared by the app, its widgets and its intents.
enum Ledger {
    /// Entries dated `start` or later, newest first.
    static func entries(since start: Date, in context: ModelContext) -> [LedgerEntry] {
        let descriptor = FetchDescriptor<LedgerEntry>(
            predicate: #Predicate<LedgerEntry> { $0.date >= start },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Spending (not money in) on the same calendar day as `day`.
    static func spent(on day: Date, in items: [LedgerItem], calendar: Calendar = .current) -> Sen {
        items.filter { !$0.isIncome && calendar.isDate($0.date, inSameDayAs: day) }.reduce(0) { $0 + $1.amount }
    }

    /// Asks the widgets to redraw after the entries change.
    static func refreshWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
