import AppIntents
import SwiftUI
import WidgetKit
import KiraCore

/// The month's two numbers with "Log again" buttons that save without opening the app,
/// plus a Lock Screen gauge of how much of the income has gone.
struct MonthWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KiraMonth", provider: KiraTimelineProvider()) { entry in
            MonthWidgetView(snapshot: entry.snapshot)
                .containerBackground(Theme.card, for: .widget)
                .widgetURL(URL(string: "kira://month"))
        }
        .configurationDisplayName("This month")
        .description("Spent and came in this month, with your regulars one tap away.")
        .supportedFamilies([.systemMedium, .accessoryCircular])
    }
}

private struct MonthWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: WidgetSnapshot

    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: min(snapshot.spentShare ?? 0, 1)) {
                Text("Spent")
            } currentValueLabel: {
                VStack(spacing: 0) {
                    Text("\(Int(((snapshot.spentShare ?? 0) * 100).rounded()))%")
                        .font(.fraunces(15, weight: 650))
                    Text("spent")
                        .font(.figtree(9, weight: 600))
                }
            }
            .gaugeStyle(.accessoryCircular)
        default:
            medium
        }
    }

    private var medium: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    AppMark(size: 22)
                    Text(snapshot.monthName)
                        .font(.figtree(15, weight: 650))
                        .foregroundStyle(Theme.ink)
                }
                .padding(.bottom, 6)
                Text("Spent")
                    .font(.figtree(13))
                    .foregroundStyle(Theme.secondary)
                Text(Money.format(snapshot.spentThisMonth, currency: true))
                    .font(.fraunces(24, weight: 650))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("Came in")
                    .font(.figtree(13))
                    .foregroundStyle(Theme.secondary)
                Text(Money.format(snapshot.cameInThisMonth, currency: true))
                    .font(.fraunces(20, weight: 650))
                    .foregroundStyle(Theme.green)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text("Log again")
                    .font(.figtree(13))
                    .foregroundStyle(Theme.secondary)
                if snapshot.regulars.isEmpty {
                    Text("Things you log often show up here.")
                        .font(.figtree(13))
                        .foregroundStyle(Theme.secondary)
                } else {
                    ForEach(snapshot.regulars) { regular in
                        Button(intent: LogAgainIntent(regular)) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Theme.accentDeep)
                                Text(regular.title)
                                    .lineLimit(1)
                                Spacer(minLength: 4)
                                Text(Money.format(regular.amount))
                                    .font(.figtree(13, weight: 700).monospacedDigit())
                            }
                            .font(.figtree(13, weight: 500))
                            .foregroundStyle(Theme.ink)
                            .padding(.horizontal, 10)
                            .frame(height: 30)
                            .background(Theme.tile, in: .capsule)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// A Lock Screen circle with what's left to spend per day for the rest of the month.
struct LeftPerDayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KiraLeftPerDay", provider: KiraTimelineProvider()) { entry in
            LeftPerDayView(snapshot: entry.snapshot)
                .containerBackground(Theme.card, for: .widget)
                .widgetURL(URL(string: "kira://month"))
        }
        .configurationDisplayName("Left per day")
        .description("What's left this month, spread over the days to come.")
        .supportedFamilies([.accessoryCircular])
    }
}

private struct LeftPerDayView: View {
    let snapshot: WidgetSnapshot

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text(snapshot.perDayLeft.map { String(Int((Double($0) / 100).rounded())) } ?? "–")
                    .font(.fraunces(17, weight: 650))
                    .minimumScaleFactor(0.6)
                    .widgetAccentable()
                Text("RM a day")
                    .font(.figtree(9, weight: 600))
            }
            .padding(4)
        }
    }
}
