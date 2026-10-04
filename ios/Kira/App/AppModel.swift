import PhotosUI
import SwiftData
import SwiftUI
import KiraCore

/// What the root view presents as a sheet. One enum, so only one sheet is ever up at a time.
enum ActiveSheet: Identifiable {
    case add
    case review(CaptureBatch)
    case edit(UUID)
    case newEntry(Date)
    case screenshot(ScreenshotBatch)

    var id: String {
        switch self {
        case .add: return "add"
        case .review(let batch): return "review-\(batch.id)"
        case .edit(let id): return "edit-\(id)"
        case .newEntry(let date): return "new-\(date.timeIntervalSince1970)"
        case .screenshot(let batch): return "screenshot-\(batch.id)"
        }
    }
}

/// What was said or typed, and the entries it became, waiting for a check before saving.
struct CaptureBatch: Identifiable {
    let id = UUID()
    var text: String
    var source: EntrySource
    var drafts: [EntryDraft]
}

/// Rows read from a screenshot, waiting for a check before saving.
struct ScreenshotBatch: Identifiable {
    let id = UUID()
    var image: UIImage?
    var drafts: [EntryDraft]
}

/// The note at the bottom of the screen after something changes, usually with Undo.
struct Toast: Identifiable {
    enum Style { case done, info }

    let id = UUID()
    var message: String
    var style: Style = .done
    var undo: (() -> Void)?
    /// Tapping the toast opens this entry.
    var editID: UUID?
}

/// App-wide state: the selected tab, what's presented, and the actions that save entries.
@MainActor
@Observable
final class AppModel {
    static let shared = AppModel()

    enum Tab: Hashable {
        case today, month, search
    }

    var tab: Tab = .today
    var tabBeforeSearch: Tab = .today
    var sheet: ActiveSheet?
    var isListening = false
    var isPickingScreenshot = false
    var isReadingScreenshot = false
    var searchText = ""
    var toast: Toast?

    @ObservationIgnored private var toastTask: Task<Void, Never>?

    var context: ModelContext { Persistence.container.mainContext }

    // MARK: Navigation

    func select(_ newTab: Tab) {
        guard newTab != tab else { return }
        if newTab == .search { tabBeforeSearch = tab }
        withAnimation(.snappy(duration: 0.3)) { tab = newTab }
    }

    func leaveSearch() {
        searchText = ""
        select(tabBeforeSearch)
    }

    /// Shows the listening screen. Siri, the Action button, the Lock Screen control and the Add sheet all come here.
    func startListening() {
        sheet = nil
        isListening = true
    }

    func pickScreenshot() {
        sheet = nil
        isListening = false
        // The photo picker can only appear once any sheet has finished closing.
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            isPickingScreenshot = true
        }
    }

    /// `kira://listen`, `kira://add`, `kira://scan`, `kira://month`, `kira://search`, `kira://today`
    func handle(_ url: URL) {
        guard url.scheme == "kira" else { return }
        switch url.host() {
        case "listen":
            startListening()
        case "add":
            isListening = false
            sheet = .add
        case "scan":
            pickScreenshot()
        case "month":
            sheet = nil
            select(.month)
        case "search":
            sheet = nil
            select(.search)
        default:
            sheet = nil
            select(.today)
        }
    }

    // MARK: Capture

    /// Entries from about the last six weeks, for duplicate checks and to place new entries on the timeline.
    func recentItems(now: Date = Date()) -> [LedgerItem] {
        let start = Calendar.current.date(byAdding: .day, value: -42, to: now) ?? now
        return Ledger.entries(since: start, in: context).map(\.item)
    }

    /// Decides what happens to entries that were said or typed. One clear entry is saved straight away with Undo.
    /// Several entries, a guessed time or a possible duplicate go to the review sheet first.
    func receive(_ drafts: [EntryDraft], from text: String, source: EntrySource) {
        guard let first = drafts.first else { return }
        let questions = DuplicateChecker.questions(for: drafts, existing: recentItems())
        if drafts.count == 1, questions.isEmpty, !first.timeWasGuessed {
            save(drafts, source: source)
        } else {
            sheet = .review(CaptureBatch(text: text, source: source, drafts: drafts))
        }
    }

    @discardableResult
    func save(_ drafts: [EntryDraft], source: EntrySource, notes: [UUID: String] = [:], announce: Bool = true) -> [LedgerEntry] {
        let saved = drafts.map { LedgerEntry(draft: $0, source: source, note: notes[$0.id] ?? "") }
        for entry in saved { context.insert(entry) }
        try? context.save()
        Ledger.refreshWidgets()
        if announce { announceSaved(saved) }
        return saved
    }

    func update(_ entry: LedgerEntry, with draft: EntryDraft, note: String) {
        entry.apply(draft, note: note)
        try? context.save()
        Ledger.refreshWidgets()
    }

    func delete(_ entry: LedgerEntry) {
        let draft = entry.draft
        let note = entry.note
        let source = entry.source
        context.delete(entry)
        try? context.save()
        Ledger.refreshWidgets()
        show(Toast(message: "Deleted \(draft.title)", undo: { [weak self] in
            _ = self?.save([draft], source: source, notes: [draft.id: note], announce: false)
        }))
    }

    func remove(_ entries: [LedgerEntry]) {
        for entry in entries { context.delete(entry) }
        try? context.save()
        Ledger.refreshWidgets()
    }

    func logAgain(_ regular: Regular) {
        let draft = EntryDraft(title: regular.title, amount: regular.amount, isIncome: false, category: regular.category, date: Date())
        save([draft], source: .quickAdd)
    }

    func readScreenshot(_ item: PhotosPickerItem) async {
        isReadingScreenshot = true
        defer { isReadingScreenshot = false }
        guard let batch = await ScreenshotReader.read(item, existing: recentItems()) else {
            show(Toast(message: "Couldn't read that image", style: .info))
            return
        }
        guard !batch.drafts.isEmpty else {
            show(Toast(message: "No amounts found in that screenshot", style: .info))
            return
        }
        sheet = .screenshot(batch)
    }

    private func announceSaved(_ saved: [LedgerEntry]) {
        guard let first = saved.first else { return }
        let message = saved.count == 1
            ? "Saved \(first.title), \(Money.format(first.amount, signed: first.isIncome))"
            : "Saved \(saved.count) entries"
        show(Toast(
            message: message,
            undo: { [weak self] in self?.remove(saved) },
            editID: saved.count == 1 ? first.uuid : nil
        ))
    }

    // MARK: Toasts

    func show(_ newToast: Toast) {
        toastTask?.cancel()
        withAnimation(.snappy) { toast = newToast }
        let id = newToast.id
        toastTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            self?.dismissToast(id)
        }
    }

    /// Hides the toast, or only the one with `id` if it is still showing.
    func dismissToast(_ id: UUID? = nil) {
        guard let current = toast, id == nil || current.id == id else { return }
        withAnimation(.snappy) { toast = nil }
    }

    // MARK: Sample month

    var hasSampleEntries: Bool {
        let sample = EntrySource.sample.rawValue
        let descriptor = FetchDescriptor<LedgerEntry>(predicate: #Predicate<LedgerEntry> { $0.sourceRaw == sample })
        return ((try? context.fetchCount(descriptor)) ?? 0) > 0
    }

    /// Fills the store with a realistic month (the one in the design) so the app can be tried before real use.
    func loadSampleMonth() {
        for item in SampleData.ledger(now: Date()) {
            context.insert(LedgerEntry(
                uuid: item.id, title: item.title, amount: item.amount, isIncome: item.isIncome,
                category: item.category, date: item.date, source: .sample
            ))
        }
        try? context.save()
        Ledger.refreshWidgets()
    }

    func removeSampleEntries() {
        let sample = EntrySource.sample.rawValue
        try? context.delete(model: LedgerEntry.self, where: #Predicate<LedgerEntry> { $0.sourceRaw == sample })
        try? context.save()
        Ledger.refreshWidgets()
    }
}
