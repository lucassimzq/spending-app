import AppIntents
import Foundation
import SwiftData
import KiraCore

/// "Hey Siri, log in Kira" → "What did you spend?" → "lunch 12 and grab 8.50". Saves without opening the app.
struct LogExpenseIntent: AppIntent {
    static let title: LocalizedStringResource = "Log spending"
    static let description: IntentDescription = IntentDescription(
        "Say what you spent or received, the way you'd text it: “lunch 12, grab 8.50, and Ali paid me back 20”."
    )

    @Parameter(title: "What happened", requestValueDialog: IntentDialog("What did you spend?"))
    var text: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let drafts = UtteranceParser().parse(text)
        guard !drafts.isEmpty else {
            return .result(dialog: "I couldn’t find an amount in that. Try something like “lunch 12”.")
        }
        let context = ModelContext(Persistence.container)
        for draft in drafts {
            context.insert(LedgerEntry(draft: draft, source: .shortcut))
        }
        try context.save()
        Ledger.refreshWidgets()
        let list = drafts
            .map { "\($0.title) \($0.isIncome ? Money.format($0.amount, signed: true) : Money.format($0.amount))" }
            .joined(separator: ", ")
        let saved = drafts.count == 1 ? "Saved \(list)." : "Saved \(drafts.count) entries: \(list)."
        return .result(dialog: "\(saved)")
    }
}

/// Opens Kira straight into listening. For the Action button, Control Center and Shortcuts.
struct StartListeningIntent: AppIntent {
    static let title: LocalizedStringResource = "Log by voice"
    static let description: IntentDescription = IntentDescription("Opens Kira and starts listening.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppModel.shared.startListening()
        return .result()
    }
}

/// Shortcuts and Siri phrases, available as soon as the app is installed.
struct KiraShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogExpenseIntent(),
            phrases: [
                "Log in \(.applicationName)",
                "Log spending in \(.applicationName)",
                "Add spending to \(.applicationName)",
            ],
            shortTitle: "Log spending",
            systemImageName: "text.bubble"
        )
        AppShortcut(
            intent: StartListeningIntent(),
            phrases: [
                "Start logging in \(.applicationName)",
                "Listen in \(.applicationName)",
            ],
            shortTitle: "Log by voice",
            systemImageName: "mic.fill"
        )
    }
}
