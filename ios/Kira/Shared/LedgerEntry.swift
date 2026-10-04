import Foundation
import SwiftData
import KiraCore

/// How an entry got into Kira.
enum EntrySource: String, Codable, CaseIterable {
    case voice, typed, manual, screenshot, shortcut, quickAdd, sample
}

/// A saved entry. Money is stored in sen so totals never drift, and the category as its raw value
/// so the store never depends on the enum's layout.
@Model
final class LedgerEntry {
    var uuid: UUID = UUID()
    var title: String = ""
    var amount: Int = 0
    var isIncome: Bool = false
    var categoryRaw: String = "other"
    var date: Date = Date()
    var timeWasGuessed: Bool = false
    var note: String = ""
    var sourceRaw: String = "manual"
    var createdAt: Date = Date()

    init(
        uuid: UUID = UUID(),
        title: String,
        amount: Int,
        isIncome: Bool,
        category: EntryCategory,
        date: Date,
        timeWasGuessed: Bool = false,
        note: String = "",
        source: EntrySource = .manual,
        createdAt: Date = Date()
    ) {
        self.uuid = uuid
        self.title = title
        self.amount = amount
        self.isIncome = isIncome
        self.categoryRaw = category.rawValue
        self.date = date
        self.timeWasGuessed = timeWasGuessed
        self.note = note
        self.sourceRaw = source.rawValue
        self.createdAt = createdAt
    }
}

extension LedgerEntry {
    convenience init(draft: EntryDraft, source: EntrySource, note: String = "") {
        self.init(
            title: draft.title,
            amount: draft.amount,
            isIncome: draft.isIncome,
            category: draft.isIncome ? .moneyIn : draft.category,
            date: draft.date,
            timeWasGuessed: draft.timeWasGuessed,
            note: note,
            source: source
        )
    }

    var category: EntryCategory {
        get { EntryCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var source: EntrySource { EntrySource(rawValue: sourceRaw) ?? .manual }

    /// The entry as the core logic sees it.
    var item: LedgerItem {
        LedgerItem(id: uuid, title: title, amount: amount, isIncome: isIncome, category: category, date: date)
    }

    /// An editable copy, used by the edit sheet.
    var draft: EntryDraft {
        EntryDraft(id: uuid, title: title, amount: amount, isIncome: isIncome, category: category, date: date,
                   timeWasGuessed: timeWasGuessed)
    }

    func apply(_ draft: EntryDraft, note: String) {
        title = draft.title
        amount = draft.amount
        isIncome = draft.isIncome
        category = draft.isIncome ? .moneyIn : draft.category
        date = draft.date
        timeWasGuessed = draft.timeWasGuessed
        self.note = note
    }
}
