import AppIntents
import Foundation
import SwiftData
import WidgetKit
import KiraCore

/// Logs one of your regulars again, at the current time. Backs the "Log again" buttons in the medium widget,
/// so it runs in the widget extension as well as in the app.
struct LogAgainIntent: AppIntent {
    static let title: LocalizedStringResource = "Log again"
    static let description: IntentDescription = IntentDescription("Logs one of your regular entries again, right now.")
    static let isDiscoverable = false

    @Parameter(title: "What")
    var entryTitle: String

    /// In sen, so RM 2.80 is 280.
    @Parameter(title: "Amount in sen")
    var amount: Int

    @Parameter(title: "Category")
    var categoryRaw: String

    init() {}

    init(_ regular: Regular) {
        self.entryTitle = regular.title
        self.amount = regular.amount
        self.categoryRaw = regular.category.rawValue
    }

    func perform() async throws -> some IntentResult {
        let context = ModelContext(Persistence.container)
        context.insert(LedgerEntry(
            title: entryTitle,
            amount: amount,
            isIncome: false,
            category: EntryCategory(rawValue: categoryRaw) ?? .other,
            date: Date(),
            source: .quickAdd
        ))
        try context.save()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
