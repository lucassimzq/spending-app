import SwiftData
import SwiftUI
import KiraCore

/// Entries that were said or typed, placed on the timeline before saving. Guessed times and possible duplicates
/// are marked, the month's totals show what saving will do, and any entry can be fixed with a tap.
struct ReviewSheet: View {
    let batch: CaptureBatch
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \LedgerEntry.date, order: .reverse) private var entries: [LedgerEntry]
    @State private var drafts: [EntryDraft]
    @State private var notes: [UUID: String] = [:]
    @State private var kept: Set<UUID> = []
    @State private var editing: EntryDraft?

    init(batch: CaptureBatch) {
        self.batch = batch
        _drafts = State(initialValue: batch.drafts)
    }

    var body: some View {
        let now = Date()
        let items = entries.map(\.item)
        let questions = DuplicateChecker.questions(for: drafts, existing: items).filter { !kept.contains($0.draftID) }
        VStack(spacing: 0) {
            SheetHeader(
                title: drafts.count == 1 ? "1 new entry" : "\(drafts.count) new entries",
                closeLabel: "Discard",
                onClose: { dismiss() },
                confirmLabel: "Save",
                canConfirm: !drafts.isEmpty,
                onConfirm: save
            )
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    QuoteCard(text: batch.text, source: batch.source)
                    ReviewTimeline(
                        drafts: drafts,
                        saved: items,
                        questions: questions,
                        now: now,
                        onSelect: { editing = $0 },
                        onKeep: { kept.insert($0) },
                        onRemove: { id in withAnimation(.snappy) { drafts.removeAll { $0.id == id } } }
                    )
                    afterSaving(items: items, now: now)
                    Text("Tap an entry to fix it before saving.")
                        .figtree(16)
                        .foregroundStyle(Theme.secondary)
                        .padding(.horizontal, 4)
                }
                .padding(.horizontal, Theme.gutter)
                .padding(.top, 6)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.background)
        .sheet(item: $editing) { draft in
            EditEntrySheet(
                draft: draft,
                note: notes[draft.id] ?? "",
                onSave: { updated, note in
                    if let index = drafts.firstIndex(where: { $0.id == updated.id }) { drafts[index] = updated }
                    notes[updated.id] = note
                },
                onRemove: { drafts.removeAll { $0.id == draft.id } }
            )
        }
    }

    private func afterSaving(items: [LedgerItem], now: Date) -> some View {
        let before = MonthSummary.make(items: items, month: now, now: now)
        let after = MonthSummary.make(items: items + drafts.map(\.ledgerItem), month: now, now: now)
        let spentChange = after.spent - before.spent
        let cameInChange = after.cameIn - before.cameIn
        return SpentAndCameIn(
            spent: after.spent,
            cameIn: after.cameIn,
            spentLabel: "Spent after saving",
            cameInLabel: "Came in after saving",
            spentDetail: spentChange == 0 ? nil : Money.format(spentChange, signed: true),
            cameInDetail: cameInChange == 0 ? nil : Money.format(cameInChange, signed: true),
            size: 28
        )
        .card()
    }

    private func save() {
        model.save(drafts, source: batch.source, notes: notes)
        dismiss()
    }
}

extension EntryDraft {
    var ledgerItem: LedgerItem {
        LedgerItem(id: id, title: title, amount: amount, isIncome: isIncome, category: category, date: date)
    }
}

/// “lunch **12**, grab **8.50**, and Ali paid me back **20**”, with a mic or keyboard to say where it came from.
private struct QuoteCard: View {
    let text: String
    let source: EntrySource

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: source == .voice ? "mic.fill" : "keyboard")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.accentDeep)
                .frame(width: 40, height: 40)
                .background(Theme.accentTint, in: .circle)
                .accessibilityHidden(true)
            quote
                .figtree(18)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .card(padding: 16)
        .accessibilityElement(children: .combine)
    }

    private var quote: Text {
        var result = Text(verbatim: "“")
        for (index, word) in text.split(separator: " ", omittingEmptySubsequences: true).enumerated() {
            let piece = (index == 0 ? "" : " ") + word
            let segment = Text(verbatim: piece)
            if word.contains(where: { $0.isNumber }) {
                result = Text("\(result)\(segment.font(Font.figtree(18, weight: 700)).foregroundStyle(Theme.accentDeep))")
            } else {
                result = Text("\(result)\(segment)")
            }
        }
        return Text("\(result)\(Text(verbatim: "”"))")
    }
}

/// New entries (highlighted) among the day's saved ones (compact), newest first.
private struct ReviewTimeline: View {
    let drafts: [EntryDraft]
    let saved: [LedgerItem]
    let questions: [DuplicateQuestion]
    let now: Date
    let onSelect: (EntryDraft) -> Void
    let onKeep: (UUID) -> Void
    let onRemove: (UUID) -> Void

    private enum Row: Identifiable {
        case day(Date)
        case draft(EntryDraft)
        case saved(LedgerItem)
        case question(DuplicateQuestion)

        var id: String {
            switch self {
            case .day(let date): return "day-\(date.timeIntervalSince1970)"
            case .draft(let draft): return "draft-\(draft.id)"
            case .saved(let item): return "saved-\(item.id)"
            case .question(let question): return "question-\(question.draftID)"
            }
        }

        var date: Date? {
            switch self {
            case .draft(let draft): return draft.date
            case .saved(let item): return item.date
            case .day, .question: return nil
            }
        }
    }

    var body: some View {
        let rows = makeRows()
        let showsNow = drafts.contains { Calendar.current.isDate($0.date, inSameDayAs: now) }
        VStack(spacing: 0) {
            if showsNow {
                TimelineRow(dot: .now, above: nil, below: rows.isEmpty ? nil : .solid) {
                    NowLabel(now: now)
                }
            }
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                let above: RailLine? = index == 0 ? (showsNow ? .solid : nil) : .solid
                let below: RailLine? = index == rows.count - 1 ? nil : .solid
                switch row {
                case .day(let date):
                    TimelineRow(dot: .none, above: above, below: below) {
                        Text(KiraFormat.dayTitle(date, now: now))
                            .figtree(16, weight: 550)
                            .foregroundStyle(Theme.secondary)
                            .padding(.vertical, 6)
                    }
                case .draft(let draft):
                    TimelineRow(dot: .new, above: above, below: below) {
                        Button { onSelect(draft) } label: { card(for: draft) }
                            .buttonStyle(PressableStyle())
                    }
                case .saved(let item):
                    TimelineRow(dot: .small, above: above, below: below, spacing: 2) {
                        HStack(spacing: 14) {
                            Text(KiraFormat.time(item.date))
                                .figtree(15, digits: true)
                                .foregroundStyle(Theme.secondary)
                                .frame(width: 76, alignment: .leading)
                            Text(item.title)
                                .figtree(17)
                                .foregroundStyle(Theme.secondary)
                                .lineLimit(1)
                            Spacer(minLength: 8)
                            Text(item.isIncome ? Money.format(item.amount, signed: true) : Money.format(item.amount))
                                .figtree(17, digits: true)
                                .foregroundStyle(item.isIncome ? Theme.green : Theme.secondary)
                        }
                        .padding(.vertical, 8)
                        .accessibilityElement(children: .combine)
                    }
                case .question(let question):
                    TimelineRow(dot: .none, above: above, below: below) {
                        DuplicateQuestionCard(
                            question: question,
                            onKeep: { onKeep(question.draftID) },
                            onRemove: { onRemove(question.draftID) }
                        )
                    }
                }
            }
        }
    }

    /// Drafts and the saved entries from the same days, newest first, with a label where the day changes
    /// and each duplicate question right under its entry.
    private func makeRows() -> [Row] {
        let calendar = Calendar.current
        let days = Set(drafts.map { calendar.startOfDay(for: $0.date) })
        let sameDays = saved.filter { days.contains(calendar.startOfDay(for: $0.date)) }
        let dated: [Row] = (drafts.map { Row.draft($0) } + sameDays.map { Row.saved($0) })
            .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }

        var rows: [Row] = []
        var currentDay: Date?
        for row in dated {
            guard let date = row.date else { continue }
            let day = calendar.startOfDay(for: date)
            if day != currentDay {
                // Today needs no label: the Now marker is above it.
                if !calendar.isDate(day, inSameDayAs: now) || currentDay != nil { rows.append(.day(day)) }
                currentDay = day
            }
            rows.append(row)
            if case .draft(let draft) = row, let question = questions.first(where: { $0.draftID == draft.id }) {
                rows.append(.question(question))
            }
        }
        return rows
    }

    private func card(for draft: EntryDraft) -> some View {
        let category = draft.isIncome ? EntryCategory.moneyIn : draft.category
        let isJustNow = !draft.timeWasGuessed && abs(draft.date.timeIntervalSince(now)) < 120
        let subtitle: String
        let tag: String
        if draft.timeWasGuessed {
            subtitle = category.name
            tag = "\(KiraFormat.time(draft.date)) · guessed"
        } else {
            subtitle = "\(category.name) · \(isJustNow ? "just now" : KiraFormat.time(draft.date))"
            tag = "New"
        }
        return EntryCard(
            title: draft.title,
            subtitle: subtitle,
            tag: tag,
            amount: draft.amount,
            isIncome: draft.isIncome,
            category: category,
            isNew: true
        )
    }
}

/// "You logged Nasi lemak at 1:15 PM. Is this a second lunch?" with the two answers.
private struct DuplicateQuestionCard: View {
    let question: DuplicateQuestion
    let onKeep: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "square.on.square")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.accentDeep)
                    .accessibilityHidden(true)
                Text(question.message)
                    .figtree(17, weight: 600)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 12) {
                AccentButton(title: "Yes, keep it", action: onKeep)
                GlassCapsuleButton(title: "No, remove", height: 56, action: onRemove)
            }
        }
        .card(padding: 18)
    }
}
