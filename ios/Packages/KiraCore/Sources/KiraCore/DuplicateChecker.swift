import Foundation

/// A question to ask before saving, e.g. "You logged Nasi lemak at 1:15 PM. Is this a second lunch?"
public struct DuplicateQuestion: Equatable, Sendable, Identifiable {
    public var id: UUID { draftID }
    public let draftID: UUID
    public let existingID: UUID
    public let message: String
}

public enum DuplicateChecker {
    /// Only drafts whose time was guessed are checked: an explicit time or "just now" means the person knows.
    /// A draft is questioned when an existing entry in the same category sits within `window` of the guessed time.
    public static func questions(
        for drafts: [EntryDraft],
        existing: [LedgerItem],
        calendar: Calendar = .current,
        window: TimeInterval = 75 * 60
    ) -> [DuplicateQuestion] {
        drafts.compactMap { draft in
            guard !draft.isIncome, !draft.isTransfer, draft.timeWasGuessed else { return nil }
            let nearby = existing.filter {
                !$0.isIncome
                    && $0.category == draft.category
                    && calendar.isDate($0.date, inSameDayAs: draft.date)
                    && abs($0.date.timeIntervalSince(draft.date)) <= window
            }
            guard let closest = nearby.min(by: {
                abs($0.date.timeIntervalSince(draft.date)) < abs($1.date.timeIntervalSince(draft.date))
            }) else { return nil }
            let thing = draft.guessedFrom.map { "a second \($0)" } ?? "the same thing"
            let message = "You logged \(closest.title) at \(KiraFormat.time(closest.date, calendar: calendar)). Is this \(thing)?"
            return DuplicateQuestion(draftID: draft.id, existingID: closest.id, message: message)
        }
    }
}
