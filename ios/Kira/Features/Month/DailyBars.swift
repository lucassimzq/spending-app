import SwiftUI
import KiraCore

/// The month's spending per day. One very big day (usually rent) is cut short with a break and labelled,
/// so it doesn't flatten every other bar.
struct DailyBars: View {
    let daily: [Sen]
    let elapsedDays: Int
    /// Today's day of the month, when this is the current month.
    let today: Int?
    /// The everyday average (without rent), drawn as a dashed line.
    let average: Sen
    let rentDays: Set<Int>

    private let chartHeight: CGFloat = 140

    var body: some View {
        let days = daily.count
        let cap = Double(max(typicalHighest, average * 2, 100))
        VStack(spacing: 8) {
            GeometryReader { proxy in
                let width = proxy.size.width
                let slot = width / CGFloat(max(days, 1))
                let barWidth = min(max(slot * 0.6, 3), 10)
                ZStack {
                    if average > 0 {
                        HorizontalLine()
                            .stroke(Theme.dot.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                            .frame(width: width, height: 1)
                            .position(x: width / 2, y: chartHeight - chartHeight * CGFloat(min(Double(average) / cap, 1)))
                    }
                    ForEach(0..<days, id: \.self) { index in
                        let day = index + 1
                        let x = slot * (CGFloat(index) + 0.5)
                        if day <= elapsedDays {
                            let value = Double(daily[index])
                            let isClipped = value > cap
                            let height = max(CGFloat(min(value, cap) / cap) * chartHeight, value > 0 ? 5 : 3)
                            Capsule()
                                .fill(day == today ? Theme.bar : Theme.barSoft)
                                .frame(width: barWidth, height: height)
                                .overlay(alignment: .top) {
                                    if isClipped {
                                        Rectangle().fill(Theme.card).frame(height: 3).offset(y: 14)
                                    }
                                }
                                .overlay(alignment: .topLeading) {
                                    if isClipped {
                                        Text(rentDays.contains(day) ? "Rent day" : Money.roundedRinggit(daily[index]))
                                            .figtree(13, weight: 550, maximumScale: 1.2)
                                            .foregroundStyle(Theme.secondary)
                                            .fixedSize()
                                            .offset(x: barWidth + 5, y: 2)
                                    }
                                }
                                .position(x: x, y: chartHeight - height / 2)
                        } else {
                            Circle()
                                .fill(Theme.track)
                                .frame(width: 5, height: 5)
                                .position(x: x, y: chartHeight - 2.5)
                        }
                    }
                }
                .frame(width: width, height: chartHeight)
            }
            .frame(height: chartHeight)

            GeometryReader { proxy in
                let slot = proxy.size.width / CGFloat(max(days, 1))
                ForEach(labelDays, id: \.self) { day in
                    Text("\(day)")
                        .figtree(14, weight: day == today ? 700 : 400, digits: true, maximumScale: 1.2)
                        .foregroundStyle(day == today ? Theme.accentDeep : Theme.secondary)
                        .fixedSize()
                        .position(x: slot * (CGFloat(day) - 0.5), y: 10)
                }
            }
            .frame(height: 20)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Daily spending")
        .accessibilityValue(accessibilitySummary)
    }

    /// The biggest day that isn't a rent day.
    private var typicalHighest: Sen {
        daily.enumerated().filter { !rentDays.contains($0.offset + 1) }.map(\.element).max() ?? 0
    }

    /// 1, 8, 15, 22 and the last day, plus today (dropping a fixed label that would crowd it).
    private var labelDays: [Int] {
        let days = daily.count
        guard days > 0 else { return [] }
        var labels = [1, 8, 15, 22, days].filter { $0 <= days }
        if let today {
            labels.removeAll { $0 != today && abs($0 - today) <= 2 }
            labels.append(today)
        }
        return Array(Set(labels)).sorted()
    }

    private var accessibilitySummary: String {
        guard elapsedDays > 0, let highest = daily.prefix(elapsedDays).max(), highest > 0,
              let index = daily.firstIndex(of: highest) else { return "Nothing spent yet" }
        var text = "Highest day: \(Money.format(highest, currency: true)) on the \(index + 1)."
        if let today, today <= daily.count {
            text += " Today: \(Money.format(daily[today - 1], currency: true))."
        }
        return text
    }
}

struct HorizontalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
