import SwiftData
import SwiftUI
import KiraCore

/// Edit one entry, or fill in a new one by hand: spent or received, the amount, what it was, the category,
/// when (on a ruler that shows the day's other entries), a note, splitting, and delete.
struct EditEntrySheet: View {
    private enum Mode {
        case saved(LedgerEntry)
        case new
        case draft(onSave: (EntryDraft, String) -> Void, onRemove: () -> Void)
    }

    private enum Field: Hashable {
        case amount, title, note
    }

    private let mode: Mode
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \LedgerEntry.date, order: .reverse) private var entries: [LedgerEntry]
    @State private var draft: EntryDraft
    @State private var note: String
    @State private var amountText: String
    @State private var lastSpendingCategory: EntryCategory
    @State private var categoryWasPicked = false
    @State private var showsNote: Bool
    @State private var confirmingDelete = false
    @FocusState private var focus: Field?

    /// Edit a saved entry.
    init(entry: LedgerEntry) {
        self.init(mode: .saved(entry), draft: entry.draft, note: entry.note)
    }

    /// Fill in a new entry by hand, on `day` (now, if `day` is today).
    init(newEntryOn day: Date) {
        let calendar = Calendar.current
        let now = Date()
        var date = now
        if !calendar.isDate(day, inSameDayAs: now) {
            date = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: day) ?? day
        }
        self.init(mode: .new, draft: EntryDraft(title: "", amount: 0, isIncome: false, category: .food, date: date), note: "")
    }

    /// Fix an entry that hasn't been saved yet (from the review or screenshot sheets).
    init(draft: EntryDraft, note: String, onSave: @escaping (EntryDraft, String) -> Void, onRemove: @escaping () -> Void) {
        self.init(mode: .draft(onSave: onSave, onRemove: onRemove), draft: draft, note: note)
    }

    private init(mode: Mode, draft: EntryDraft, note: String) {
        self.mode = mode
        _draft = State(initialValue: draft)
        _note = State(initialValue: note)
        _amountText = State(initialValue: draft.amount > 0 ? Money.format(draft.amount) : "")
        _lastSpendingCategory = State(initialValue: draft.category == .moneyIn ? .other : draft.category)
        _showsNote = State(initialValue: !note.isEmpty)
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(
                title: isNew ? "New entry" : "Edit entry",
                onClose: { dismiss() },
                canConfirm: draft.amount > 0,
                onConfirm: save
            )
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SpentReceivedPicker(isIncome: $draft.isIncome)
                    amountRow
                    whatField
                    if !draft.isIncome { categoryPicker }
                    whenCard
                    noteAndSplit
                    if !isNew { deleteButton }
                }
                .padding(.horizontal, Theme.gutter)
                .padding(.top, 6)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.background)
        .onChange(of: amountText) { _, text in
            if text.trimmingCharacters(in: .whitespaces).isEmpty {
                draft.amount = 0
            } else if let sen = Money.sen(from: text) {
                draft.amount = sen
            }
        }
        .onChange(of: draft.isIncome) { _, isIncome in
            if isIncome {
                if draft.category != .moneyIn { lastSpendingCategory = draft.category }
                draft.category = .moneyIn
            } else {
                draft.category = lastSpendingCategory
            }
        }
        .onChange(of: draft.title) { _, title in
            // A new entry picks its category from the title until you choose one yourself.
            guard isNew, !categoryWasPicked, !draft.isIncome else { return }
            let guess = EntryCategory.guess(from: title)
            if guess != .other { draft.category = guess }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focus = nil }
                    .figtree(17, weight: 650)
            }
        }
        .confirmationDialog("Delete this entry?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete entry", role: .destructive) { delete() }
        }
        .onAppear {
            if isNew { focus = .amount }
        }
    }

    private var isNew: Bool {
        if case .new = mode { return true }
        return false
    }

    // MARK: Parts

    private var amountRow: some View {
        HStack(spacing: 12) {
            GlassIconButton(systemImage: "minus", label: "One ringgit less", size: 50) { nudge(by: -100) }
            Spacer(minLength: 0)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("RM")
                    .figtree(22, weight: 650)
                    .foregroundStyle(Theme.secondary)
                TextField("0.00", text: $amountText)
                    .keyboardType(.decimalPad)
                    .fraunces(62, weight: 640, relativeTo: .largeTitle, maximumScale: 1.2)
                    .foregroundStyle(draft.isIncome ? Theme.green : Theme.ink)
                    .fixedSize()
                    .focused($focus, equals: .amount)
                    .accessibilityLabel("Amount in ringgit")
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            Spacer(minLength: 0)
            GlassIconButton(systemImage: "plus", label: "One ringgit more", size: 50) { nudge(by: 100) }
        }
        .sensoryFeedback(.increase, trigger: draft.amount)
    }

    private var whatField: some View {
        HStack(spacing: 14) {
            Text("What")
                .figtree(18)
                .foregroundStyle(Theme.secondary)
            TextField(draft.isIncome ? "Salary" : "Lunch", text: $draft.title)
                .figtree(19, weight: 600)
                .foregroundStyle(Theme.ink)
                .focused($focus, equals: .title)
                .submitLabel(.done)
        }
        .padding(.horizontal, 20)
        .frame(minHeight: 60)
        .background(Theme.card, in: .rect(cornerRadius: 22))
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Category")
                .figtree(16, weight: 500)
                .foregroundStyle(Theme.secondary)
                .padding(.horizontal, 4)
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(EntryCategory.spending) { category in
                        ChoiceChip(title: category.name, systemImage: category.symbol, isSelected: draft.category == category) {
                            draft.category = category
                            categoryWasPicked = true
                        }
                    }
                }
                .padding(.horizontal, Theme.gutter)
                .padding(.vertical, 6)
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, -Theme.gutter)
        }
    }

    private var whenCard: some View {
        let calendar = Calendar.current
        let others = entries
            .filter { $0.uuid != draft.id && calendar.isDate($0.date, inSameDayAs: draft.date) }
            .map(\.item)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("When")
                    .figtree(18)
                    .foregroundStyle(Theme.secondary)
                Spacer(minLength: 8)
                Text("\(KiraFormat.dayTitle(draft.date)) · \(KiraFormat.time(draft.date))")
                    .figtree(18, weight: 650)
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if draft.timeWasGuessed { InfoTag(text: "Guessed") }
            }
            TimeRuler(date: $draft.date, otherTimes: others.map(\.date)) {
                draft.timeWasGuessed = false
            }
            if let caption = rulerCaption(others: others) {
                Text(caption)
                    .figtree(15)
                    .foregroundStyle(Theme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Text("Day")
                    .figtree(17)
                    .foregroundStyle(Theme.secondary)
                Spacer()
                DatePicker("Day", selection: dayBinding, in: ...Date(), displayedComponents: .date)
                    .labelsHidden()
                    .tint(Theme.accentDeep)
            }
        }
        .card()
    }

    private var noteAndSplit: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.snappy) { showsNote.toggle() }
                if showsNote { focus = .note }
            } label: {
                OptionRow(systemImage: "doc.text", title: "Note", value: note.isEmpty ? "Add" : nil)
            }
            .buttonStyle(.plain)
            if showsNote {
                TextField("A note for yourself", text: $note, axis: .vertical)
                    .figtree(17)
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1...5)
                    .focused($focus, equals: .note)
                    .padding(.leading, 74)
                    .padding(.trailing, 16)
                    .padding(.bottom, 14)
            }
            Rectangle()
                .fill(Theme.separator)
                .frame(height: 1)
                .padding(.leading, 74)
            Menu {
                ForEach(2...5, id: \.self) { people in
                    Button("Split \(people) ways") { split(between: people) }
                }
            } label: {
                OptionRow(systemImage: "person.2", title: "Split with someone", value: nil)
            }
            .buttonStyle(.plain)
            .disabled(draft.amount == 0)
        }
        .background(Theme.card, in: .rect(cornerRadius: Theme.cardRadius))
    }

    private var deleteButton: some View {
        Button {
            if case .saved = mode {
                confirmingDelete = true
            } else {
                delete()
            }
        } label: {
            Text(isSavedEntry ? "Delete entry" : "Remove entry")
                .figtree(19, weight: 650)
                .foregroundStyle(Theme.red)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Theme.card, in: .rect(cornerRadius: 22))
        }
        .buttonStyle(PressableStyle())
    }

    private var isSavedEntry: Bool {
        if case .saved = mode { return true }
        return false
    }

    /// Changing the day keeps the time of day.
    private var dayBinding: Binding<Date> {
        Binding(
            get: { draft.date },
            set: { newDay in
                let calendar = Calendar.current
                let time = calendar.dateComponents([.hour, .minute], from: draft.date)
                draft.date = calendar.date(bySettingHour: time.hour ?? 12, minute: time.minute ?? 0, second: 0, of: newDay) ?? newDay
            }
        )
    }

    /// "Dots are your other entries today. Nasi lemak is at 1:15 PM, so check this isn't the same lunch."
    private func rulerCaption(others: [LedgerItem]) -> String? {
        guard !others.isEmpty else { return nil }
        let isToday = Calendar.current.isDateInToday(draft.date)
        var caption = "Dots are your other entries \(isToday ? "today" : "that day")."
        let close = others
            .filter { !draft.isIncome && !$0.isIncome && $0.category == draft.category && abs($0.date.timeIntervalSince(draft.date)) <= 75 * 60 }
            .min { abs($0.date.timeIntervalSince(draft.date)) < abs($1.date.timeIntervalSince(draft.date)) }
        if let close {
            let what = draft.guessedFrom ?? "thing"
            caption += " \(close.title) is at \(KiraFormat.time(close.date)), so check this isn\u{2019}t the same \(what)."
        }
        return caption
    }

    // MARK: Actions

    private func nudge(by sen: Sen) {
        draft.amount = max(0, draft.amount + sen)
        amountText = draft.amount > 0 ? Money.format(draft.amount) : ""
    }

    private func split(between people: Int) {
        let total = draft.amount
        draft.amount = Int((Double(total) / Double(people)).rounded())
        amountText = Money.format(draft.amount)
        let line = "Split \(people) ways from \(Money.format(total, currency: true))."
        note = note.isEmpty ? line : note + "\n" + line
        showsNote = true
    }

    private func save() {
        var result = draft
        result.title = result.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.isIncome { result.category = .moneyIn }
        if result.title.isEmpty { result.title = result.category.name }
        switch mode {
        case .saved(let entry):
            model.update(entry, with: result, note: note)
        case .new:
            model.save([result], source: .manual)
        case .draft(let onSave, _):
            onSave(result, note)
        }
        dismiss()
    }

    private func delete() {
        switch mode {
        case .saved(let entry):
            model.delete(entry)
        case .new:
            break
        case .draft(_, let onRemove):
            onRemove()
        }
        dismiss()
    }
}

/// Spent or received, as a two-part control with a sliding white pill.
private struct SpentReceivedPicker: View {
    @Binding var isIncome: Bool
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 4) {
            segment("Spent", isSelected: !isIncome) { isIncome = false }
            segment("Received", isSelected: isIncome) { isIncome = true }
        }
        .padding(5)
        .background(Theme.track, in: .capsule)
        .sensoryFeedback(.selection, trigger: isIncome)
    }

    private func segment(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.25)) { action() }
        } label: {
            Text(title)
                .figtree(18, weight: isSelected ? 650 : 500)
                .foregroundStyle(isSelected ? Theme.ink : Theme.secondary)
                .frame(maxWidth: .infinity, minHeight: 46)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Theme.card)
                            .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                            .matchedGeometryEffect(id: "pill", in: pill)
                    }
                }
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// A row in the note and split card: icon tile, title, an optional value and ›.
private struct OptionRow: View {
    let systemImage: String
    let title: String
    let value: String?

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Theme.ink)
                .frame(width: 42, height: 42)
                .background(Theme.tile, in: .rect(cornerRadius: 12))
            Text(title)
                .figtree(19)
                .foregroundStyle(Theme.ink)
            Spacer(minLength: 8)
            if let value {
                Text(value)
                    .figtree(18)
                    .foregroundStyle(Theme.secondary)
            }
            Chevron()
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 64)
        .contentShape(.rect)
    }
}
