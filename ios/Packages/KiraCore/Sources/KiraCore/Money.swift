import Foundation

/// Amounts are stored in sen (1/100 of a ringgit) so totals never pick up floating-point rounding.
public typealias Sen = Int

public enum Money {
    /// Formats sen as ringgit: `214630` → `"2,146.30"`, or `"RM 2,146.30"` with `currency`.
    /// Negative amounts use a real minus sign; `signed` adds a plus sign to positive amounts.
    public static func format(_ sen: Sen, currency: Bool = false, signed: Bool = false) -> String {
        let magnitude = sen.magnitude
        let ringgit = Int(magnitude / 100)
        let cents = Int(magnitude % 100)
        var text = groupThousands(ringgit) + "." + (cents < 10 ? "0" : "") + String(cents)
        if currency { text = "RM " + text }
        if sen < 0 {
            text = "\u{2212}" + text
        } else if signed {
            text = "+" + text
        }
        return text
    }

    /// Whole ringgit, rounded: `1629` → `"RM 16"`. Used in friendly sentences ("about RM 16 a ride").
    public static func roundedRinggit(_ sen: Sen) -> String {
        let ringgit = Int((Double(sen) / 100).rounded())
        return "RM " + groupThousands(ringgit)
    }

    /// Parses what someone typed into an amount field: "12", "12.5", "12.50", "1,234.50", "RM 8".
    public static func sen(from text: String) -> Sen? {
        var cleaned = text.lowercased()
            .replacingOccurrences(of: "rm", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)
        if cleaned.hasPrefix(".") { cleaned = "0" + cleaned }
        guard !cleaned.isEmpty else { return nil }
        let parts = cleaned.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count <= 2, let whole = Int(parts[0]), whole >= 0, whole < 100_000_000 else { return nil }
        var cents = 0
        if parts.count == 2 {
            let fraction = String(parts[1])
            guard fraction.count <= 2, fraction.allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
            if !fraction.isEmpty {
                cents = Int(fraction.padding(toLength: 2, withPad: "0", startingAt: 0)) ?? 0
            }
        }
        return whole * 100 + cents
    }

    /// The value as a `Double`, for charts and animations.
    public static func double(_ sen: Sen) -> Double { Double(sen) / 100 }

    static func groupThousands(_ value: Int) -> String {
        let digits = String(value)
        var out = ""
        for (index, character) in digits.enumerated() {
            if index > 0 && (digits.count - index) % 3 == 0 { out.append(",") }
            out.append(character)
        }
        return out
    }
}
