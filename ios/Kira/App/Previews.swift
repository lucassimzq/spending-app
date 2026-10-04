#if DEBUG
import SwiftData
import SwiftUI
import KiraCore

/// An in-memory store filled with the design's sample month, for Xcode previews.
@MainActor
enum PreviewStore {
    static let container: ModelContainer = {
        let container = Persistence.inMemory()
        for item in SampleData.ledger(now: Date()) {
            container.mainContext.insert(LedgerEntry(
                uuid: item.id, title: item.title, amount: item.amount, isIncome: item.isIncome,
                category: item.category, date: item.date, source: .sample
            ))
        }
        return container
    }()
}

#Preview("Today") {
    TodayScreen()
        .environment(AppModel.shared)
        .modelContainer(PreviewStore.container)
}

#Preview("Month") {
    MonthScreen()
        .environment(AppModel.shared)
        .modelContainer(PreviewStore.container)
}

#Preview("Search") {
    SearchScreen()
        .environment(AppModel.shared)
        .modelContainer(PreviewStore.container)
}

#Preview("New entry") {
    EditEntrySheet(newEntryOn: Date())
        .environment(AppModel.shared)
        .modelContainer(PreviewStore.container)
}

#Preview("Review") {
    let drafts = UtteranceParser().parse("lunch 12, grab 8.50, and Ali paid me back 20")
    ReviewSheet(batch: CaptureBatch(text: "lunch 12, grab 8.50, and Ali paid me back 20", source: .voice, drafts: drafts))
        .environment(AppModel.shared)
        .modelContainer(PreviewStore.container)
}
#endif
