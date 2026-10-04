import SwiftUI
import WidgetKit
import KiraCore

/// Today's spending: a small Home Screen widget, a Lock Screen rectangle, and an inline line.
struct TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KiraToday", provider: KiraTimelineProvider()) { entry in
            TodayWidgetView(snapshot: entry.snapshot)
                .containerBackground(Theme.card, for: .widget)
                .widgetURL(URL(string: "kira://today"))
        }
        .configurationDisplayName("Today")
        .description("What you've spent today, and your latest entries.")
        .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryInline])
    }
}

private struct TodayWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: WidgetSnapshot

    var body: some View {
        switch family {
        case .accessoryRectangular:
            rectangular
        case .accessoryInline:
            Text("\(Money.format(snapshot.spentToday, currency: true)) spent today")
        default:
            small
        }
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                AppMark(size: 22)
                Text("Today")
                    .font(.figtree(15, weight: 650))
                    .foregroundStyle(Theme.ink)
            }
            Spacer(minLength: 6)
            Text(Money.format(snapshot.spentToday, currency: true))
                .font(.fraunces(28, weight: 650))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(snapshot.todayCount == 1 ? "1 entry" : "\(snapshot.todayCount) entries")
                .font(.figtree(13))
                .foregroundStyle(Theme.secondary)
            Spacer(minLength: 6)
            ForEach(snapshot.today.prefix(2)) { item in
                HStack {
                    Text(item.title)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(item.isIncome ? Money.format(item.amount, signed: true) : Money.format(item.amount))
                        .font(.figtree(13, weight: 650).monospacedDigit())
                        .foregroundStyle(item.isIncome ? Theme.green : Theme.ink)
                }
                .font(.figtree(13))
                .foregroundStyle(Theme.ink)
            }
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Kira · Spent today")
                .font(.figtree(13, weight: 600))
            Text(Money.format(snapshot.spentToday, currency: true))
                .font(.fraunces(22, weight: 650))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .widgetAccentable()
            if let last = snapshot.today.first {
                Text("Last: \(last.title), \(Money.format(last.amount))")
                    .font(.figtree(13))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
