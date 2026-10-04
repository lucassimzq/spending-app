import Foundation
import SwiftData
import WidgetKit
import KiraCore

/// Everything the widgets show, read from the shared store.
struct WidgetSnapshot {
    var monthName: String
    var spentThisMonth: Sen
    var cameInThisMonth: Sen
    var spentShare: Double?
    var perDayLeft: Sen?
    var spentToday: Sen
    var todayCount: Int
    /// Today's entries, newest first.
    var today: [LedgerItem]
    var regulars: [Regular]

    static func load(now: Date = Date()) -> WidgetSnapshot {
        let calendar = Calendar.current
        let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let sixtyDaysAgo = calendar.date(byAdding: .day, value: -60, to: now) ?? now
        let context = ModelContext(Persistence.container)
        let items = Ledger.entries(since: min(monthStart, sixtyDaysAgo), in: context).map(\.item)
        return make(items: items, now: now, calendar: calendar)
    }

    static func make(items: [LedgerItem], now: Date, calendar: Calendar = .current) -> WidgetSnapshot {
        let summary = MonthSummary.make(items: items, month: now, now: now, calendar: calendar)
        let today = items
            .filter { calendar.isDate($0.date, inSameDayAs: now) }
            .sorted { $0.date > $1.date }
        return WidgetSnapshot(
            monthName: KiraFormat.monthName(summary.start, calendar: calendar),
            spentThisMonth: summary.spent,
            cameInThisMonth: summary.cameIn,
            spentShare: summary.spentShare,
            perDayLeft: summary.perDayLeft,
            spentToday: today.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount },
            todayCount: today.count,
            today: today,
            regulars: Regulars.top(from: items, now: now, limit: 3, calendar: calendar)
        )
    }

    /// The design's sample month, for the widget gallery and placeholders.
    static var sample: WidgetSnapshot {
        let now = Date()
        return make(items: SampleData.ledger(now: now), now: now)
    }
}

struct KiraWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

/// Refreshes every half hour and at midnight. The app and the intents also reload the widgets after each change.
struct KiraTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> KiraWidgetEntry {
        KiraWidgetEntry(date: Date(), snapshot: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (KiraWidgetEntry) -> Void) {
        let snapshot = context.isPreview ? WidgetSnapshot.sample : WidgetSnapshot.load()
        completion(KiraWidgetEntry(date: Date(), snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KiraWidgetEntry>) -> Void) {
        let now = Date()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(86_400)
        let next = min(calendar.startOfDay(for: tomorrow), now.addingTimeInterval(30 * 60))
        let entry = KiraWidgetEntry(date: now, snapshot: .load(now: now))
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}
