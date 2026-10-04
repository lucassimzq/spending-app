import SwiftUI
import KiraCore

/// What was read from a screenshot, ready to save. Rows you've already logged are skipped, and a wallet
/// reload is shown but not counted as spending unless you say so.
struct ScreenshotImportSheet: View {
    let batch: ScreenshotBatch
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var drafts: [EntryDraft]
    @State private var notes: [UUID: String] = [:]
    @State private var countReloads = false
    @State private var editing: EntryDraft?
    private let skipped: Int

    init(batch: ScreenshotBatch) {
        self.batch = batch
        _drafts = State(initialValue: batch.drafts.filter { !$0.isAlreadyLogged })
        skipped = batch.drafts.filter(\.isAlreadyLogged).count
    }

    var body: some View {
        let reloads = drafts.filter(\.isTransfer)
        VStack(spacing: 0) {
            SheetHeader(
                title: "From a screenshot",
                onClose: { dismiss() },
                canConfirm: !toSave.isEmpty,
                onConfirm: save
            )
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 16) {
                        if let image = batch.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 128, height: 210, alignment: .top)
                                .clipShape(.rect(cornerRadius: 20))
                                .overlay { RoundedRectangle(cornerRadius: 20).strokeBorder(Theme.separator, lineWidth: 1) }
                                .accessibilityLabel("Your screenshot")
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Found \(drafts.count)")
                                .fraunces(36, weight: 650, wonky: true)
                                .foregroundStyle(Theme.ink)
                            Text(summary)
                                .figtree(17)
                                .foregroundStyle(Theme.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            if !reloads.isEmpty {
                                AITip(text: reloads.count == 1
                                      ? "A reload just moves your money, so it isn’t counted as spending."
                                      : "Reloads just move your money, so they aren’t counted as spending.")
                            }
                        }
                    }

                    if !drafts.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(Array(drafts.enumerated()), id: \.element.id) { index, draft in
                                Button { editing = draft } label: { row(for: draft) }
                                    .buttonStyle(PressableStyle())
                                if index < drafts.count - 1 || !reloads.isEmpty {
                                    Rectangle().fill(Theme.separator).frame(height: 1).padding(.leading, 62)
                                }
                            }
                            if !reloads.isEmpty {
                                Toggle(isOn: $countReloads) {
                                    Text(reloads.count == 1 ? "Count the reload as spending" : "Count reloads as spending")
                                        .figtree(18)
                                        .foregroundStyle(Theme.ink)
                                }
                                .tint(Theme.accent)
                                .padding(.vertical, 14)
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(Theme.card, in: .rect(cornerRadius: Theme.cardRadius))
                    }

                    Text("Check the category and time, then tap ✓ to save. Tap a row to change it.")
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

    private var summary: String {
        var text = "Read from your screenshot."
        if skipped == 1 { text += " One row was already logged, so it’s left out." }
        if skipped > 1 { text += " \(skipped) rows were already logged, so they’re left out." }
        return text
    }

    /// Everything except reloads, unless reloads should count as spending.
    private var toSave: [EntryDraft] {
        drafts.compactMap { draft in
            guard draft.isTransfer else { return draft }
            guard countReloads else { return nil }
            var spending = draft
            spending.isTransfer = false
            spending.isIncome = false
            return spending
        }
    }

    private func row(for draft: EntryDraft) -> some View {
        let category = draft.isIncome ? EntryCategory.moneyIn : draft.category
        let what = draft.isTransfer ? "Wallet top-up" : category.name
        return HStack(spacing: 14) {
            CategoryTile(category: category, size: 46, isTransfer: draft.isTransfer)
            VStack(alignment: .leading, spacing: 3) {
                Text(draft.title)
                    .figtree(18, weight: 550)
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text("\(what) · \(KiraFormat.time(draft.date))")
                        .figtree(15)
                        .foregroundStyle(Theme.secondary)
                        .lineLimit(1)
                    if draft.timeWasGuessed { InfoTag(text: "Time guessed") }
                }
            }
            Spacer(minLength: 8)
            AmountLabel(amount: draft.amount, isIncome: draft.isIncome, strikethrough: draft.isTransfer && !countReloads)
            Chevron()
        }
        .padding(.vertical, 12)
        .contentShape(.rect)
    }

    private func save() {
        model.save(toSave, source: .screenshot, notes: notes)
        dismiss()
    }
}
