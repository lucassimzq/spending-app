import SwiftUI
import KiraCore

/// A big amount in Fraunces with a small raised "RM", rolling to new values.
struct MoneyText: View {
    let sen: Sen
    var size: CGFloat = 30
    var color: Color = Theme.ink
    var signed = false
    @ScaledMetric(relativeTo: .title) private var scale: CGFloat = 1

    var body: some View {
        let scaled = size * min(scale, 1.35)
        HStack(alignment: .firstTextBaseline, spacing: scaled * 0.16) {
            Text("RM")
                .font(.figtree(scaled * 0.42, weight: 650))
                .alignmentGuide(.firstTextBaseline) { dimensions in
                    dimensions[.firstTextBaseline] + scaled * 0.28
                }
            Text(Money.format(sen, signed: signed))
                .font(.fraunces(scaled, weight: 640))
                .contentTransition(.numericText(value: Double(sen)))
        }
        .foregroundStyle(color)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .animation(.snappy, value: sen)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Money.format(sen, currency: true, signed: signed))
    }
}

/// A label with a big amount under it, and an optional line under that.
struct LabeledMoney: View {
    let label: String
    let sen: Sen
    var color: Color = Theme.ink
    var size: CGFloat = 30
    var detail: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .figtree(15)
                .foregroundStyle(Theme.secondary)
            MoneyText(sen: sen, size: size, color: color)
            if let detail {
                Text(detail)
                    .figtree(14, digits: true)
                    .foregroundStyle(color == Theme.green ? Theme.green : Theme.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// Money out and money in, side by side: the two numbers that matter most.
struct SpentAndCameIn: View {
    let spent: Sen
    let cameIn: Sen
    var spentLabel = "Spent"
    var cameInLabel = "Came in"
    var spentDetail: String?
    var cameInDetail: String?
    var size: CGFloat = 30

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            LabeledMoney(label: spentLabel, sen: spent, color: Theme.ink, size: size, detail: spentDetail)
            LabeledMoney(label: cameInLabel, sen: cameIn, color: Theme.green, size: size, detail: cameInDetail)
        }
    }
}

/// An amount in a row: "5.00", or "+400.00" in green for money in.
struct AmountLabel: View {
    let amount: Sen
    let isIncome: Bool
    var strikethrough = false
    var size: CGFloat = 18

    var body: some View {
        Text(isIncome ? Money.format(amount, signed: true) : Money.format(amount))
            .strikethrough(strikethrough)
            .figtree(size, weight: 500, digits: true)
            .foregroundStyle(isIncome ? Theme.green : Theme.ink)
            .lineLimit(1)
            .fixedSize()
    }
}
