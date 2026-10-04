import Foundation

/// The one-line answer above search results, worked out from the matches (no model needed):
/// "9 Grab rides this month, RM 146.60 in total. That’s about RM 16 a ride."
public enum SearchAnswer {
    private static let rideWords: Set<String> = ["grab", "taxi", "ride", "rides", "e-hailing", "ehailing", "indrive", "maxim"]

    public static func sentence(for query: String, matches: [LedgerItem], period: String = "this month") -> String? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return nil }
        let spending = matches.filter { !$0.isIncome }
        let income = matches.filter { $0.isIncome }

        if spending.isEmpty {
            guard !income.isEmpty else { return nil }
            let total = income.reduce(0) { $0 + $1.amount }
            let entries = income.count == 1 ? "1 entry" : "\(income.count) entries"
            return "\(Money.format(total, currency: true)) came in \(period) from \(entries) matching “\(trimmed)”."
        }

        let total = spending.reduce(0) { $0 + $1.amount }
        let count = spending.count
        let isRide = rideWords.contains(trimmed.lowercased()) && spending.allSatisfy { $0.category == .transport }
        let name = trimmed.prefix(1).uppercased() + trimmed.dropFirst()
        let singular = isRide ? "\(name) ride" : "entry for “\(trimmed)”"
        let plural = isRide ? "\(name) rides" : "entries for “\(trimmed)”"
        let each = isRide ? "a ride" : "each"

        if count == 1 {
            return "1 \(singular) \(period), \(Money.format(total, currency: true))."
        }
        return "\(count) \(plural) \(period), \(Money.format(total, currency: true)) in total. That\u{2019}s about \(Money.roundedRinggit(total / count)) \(each)."
    }
}
