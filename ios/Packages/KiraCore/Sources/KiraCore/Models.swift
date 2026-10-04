import Foundation

/// Something the app understood but hasn't saved yet: from speech, typing, a screenshot or a shortcut.
public struct EntryDraft: Equatable, Sendable, Identifiable {
    public var id: UUID
    public var title: String
    public var amount: Sen
    public var isIncome: Bool
    public var category: EntryCategory
    public var date: Date
    /// True when the time came from a word like "lunch" rather than the clock or an explicit time.
    public var timeWasGuessed: Bool
    /// The word the time was guessed from, e.g. "lunch".
    public var guessedFrom: String?
    /// The part of the sentence (or screenshot row) this draft came from.
    public var sourceText: String
    /// Money moved between your own accounts, such as an e-wallet reload. Not spending, not income.
    public var isTransfer: Bool
    /// A screenshot row that matches an entry you already have.
    public var isAlreadyLogged: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        amount: Sen,
        isIncome: Bool,
        category: EntryCategory,
        date: Date,
        timeWasGuessed: Bool = false,
        guessedFrom: String? = nil,
        sourceText: String = "",
        isTransfer: Bool = false,
        isAlreadyLogged: Bool = false
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.isIncome = isIncome
        self.category = category
        self.date = date
        self.timeWasGuessed = timeWasGuessed
        self.guessedFrom = guessedFrom
        self.sourceText = sourceText
        self.isTransfer = isTransfer
        self.isAlreadyLogged = isAlreadyLogged
    }
}

/// A saved entry, as the core logic sees it. The app maps its SwiftData model to this.
public struct LedgerItem: Equatable, Sendable, Identifiable {
    public var id: UUID
    public var title: String
    public var amount: Sen
    public var isIncome: Bool
    public var category: EntryCategory
    public var date: Date

    public init(id: UUID = UUID(), title: String, amount: Sen, isIncome: Bool, category: EntryCategory, date: Date) {
        self.id = id
        self.title = title
        self.amount = amount
        self.isIncome = isIncome
        self.category = category
        self.date = date
    }
}
