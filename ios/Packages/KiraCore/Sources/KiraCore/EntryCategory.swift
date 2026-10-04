import Foundation

/// Where money went (or `moneyIn` when it came in). Raw values are stored, so never rename them.
public enum EntryCategory: String, CaseIterable, Codable, Sendable, Identifiable {
    case food
    case groceries
    case transport
    case shopping
    case bills
    case rent
    case other
    case moneyIn

    public var id: String { rawValue }

    public var name: String {
        switch self {
        case .food: return "Food"
        case .groceries: return "Groceries"
        case .transport: return "Transport"
        case .shopping: return "Shopping"
        case .bills: return "Bills"
        case .rent: return "Rent"
        case .other: return "Other"
        case .moneyIn: return "Money in"
        }
    }

    /// SF Symbol shown in the category tile.
    public var symbol: String {
        switch self {
        case .food: return "fork.knife"
        case .groceries: return "cart"
        case .transport: return "car"
        case .shopping: return "bag"
        case .bills: return "bolt"
        case .rent: return "house"
        case .other: return "square.grid.2x2"
        case .moneyIn: return "arrow.down.left"
        }
    }

    /// Categories you can pick for spending, in the order the edit screen shows them.
    public static let spending: [EntryCategory] = [.food, .groceries, .transport, .shopping, .bills, .rent, .other]

    /// The spending category a title suggests ("Grab ride home" → transport), or `.other` when nothing matches.
    public static func guess(from title: String) -> EntryCategory {
        Lexicon.category(for: title.lowercased())
    }

    /// True when a title reads like money coming in: "salary", "refund", "Ali paid me back".
    public static func soundsLikeIncome(_ title: String) -> Bool {
        Lexicon.income.matchesAny(title.lowercased())
    }

    /// Parses loose text from the on-device model ("Food", "groceries", "money in").
    public init?(loose text: String) {
        let key = text.lowercased().replacingOccurrences(of: " ", with: "")
        if let match = EntryCategory.allCases.first(where: { $0.rawValue.lowercased() == key || $0.name.lowercased().replacingOccurrences(of: " ", with: "") == key }) {
            self = match
        } else {
            return nil
        }
    }
}
