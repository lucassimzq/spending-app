import PhotosUI
import SwiftData
import SwiftUI
import KiraCore

/// The glass Add sheet: talk, type, pick a screenshot, or log a regular again in one tap.
struct AddSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \LedgerEntry.date, order: .reverse) private var entries: [LedgerEntry]
    @State private var isTyping = false
    @State private var typed = ""
    @State private var pickedScreenshot: PhotosPickerItem?
    @FocusState private var fieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            header
            if isTyping {
                typing
            } else {
                choices
            }
            Spacer(minLength: 0)
        }
        .presentationDetents(isTyping ? [.large] : [.height(500), .large])
        .presentationDragIndicator(.visible)
        .onChange(of: pickedScreenshot) { _, item in
            guard let item else { return }
            pickedScreenshot = nil
            dismiss()
            Task { await model.readScreenshot(item) }
        }
    }

    private var header: some View {
        ZStack {
            Text(isTyping ? "Type it" : "Add")
                .figtree(20, weight: 650)
                .foregroundStyle(Theme.ink)
                .accessibilityAddTraits(.isHeader)
            HStack {
                if isTyping {
                    GlassIconButton(systemImage: "chevron.left", label: "Back") {
                        withAnimation(.snappy) { isTyping = false }
                    }
                }
                Spacer()
                GlassIconButton(systemImage: "xmark", label: "Close") { dismiss() }
            }
        }
        .padding(.horizontal, Theme.gutter)
        .padding(.top, 20)
    }

    // MARK: Choices

    private var choices: some View {
        VStack(spacing: 0) {
            Button { model.startListening() } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 110, height: 110)
                    .background(Theme.accentFill, in: .circle)
                    .shadow(color: Theme.accent.opacity(0.45), radius: 22, y: 8)
                    .contentShape(.circle)
            }
            .buttonStyle(PressableStyle())
            .accessibilityLabel("Talk")
            .accessibilityHint("Say what you spent, a few at once if you like")
            .padding(.top, 18)

            Text("Tap to talk")
                .figtree(20, weight: 650)
                .foregroundStyle(Theme.ink)
                .padding(.top, 18)
            Text("Say a few at once: “lunch 12, grab 8.50”")
                .figtree(16)
                .foregroundStyle(Theme.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .padding(.horizontal, Theme.gutter)

            HStack(spacing: 14) {
                GlassCapsuleButton(title: "Type it", systemImage: "keyboard") {
                    withAnimation(.snappy) { isTyping = true }
                }
                PhotosPicker(selection: $pickedScreenshot, matching: .screenshots) {
                    GlassCapsuleLabel(title: "Screenshot", systemImage: "text.viewfinder")
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .capsule)
            }
            .padding(.horizontal, Theme.gutter)
            .padding(.top, 24)

            if !regulars.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Log again")
                        .figtree(16, weight: 500)
                        .foregroundStyle(Theme.secondary)
                        .padding(.horizontal, Theme.gutter + 4)
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(regulars) { regular in
                                LogAgainChip(regular: regular) {
                                    model.logAgain(regular)
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal, Theme.gutter)
                        .padding(.vertical, 6)
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(.top, 24)
            }
        }
    }

    private var regulars: [Regular] {
        Regulars.top(from: entries.prefix(400).map(\.item))
    }

    // MARK: Typing

    private var typing: some View {
        let drafts = UtteranceParser().parse(typed)
        return VStack(alignment: .leading, spacing: 18) {
            TextField("lunch 12, grab 8.50", text: $typed, axis: .vertical)
                .fraunces(30, weight: 500, italic: true, wonky: true, relativeTo: .title)
                .foregroundStyle(Theme.ink)
                .lineLimit(1...4)
                .focused($fieldFocused)
                .submitLabel(.done)
                .onChange(of: typed) { _, text in
                    // The field wraps long sentences, so Return arrives as a new line: treat it as Add.
                    guard text.contains("\n") else { return }
                    typed = text.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespaces)
                    submit(UtteranceParser().parse(typed))
                }
                .padding(20)
                .background(Theme.card, in: .rect(cornerRadius: Theme.cardRadius))

            if drafts.isEmpty {
                Text("Write it like a text: what, then how much. Several at once is fine.")
                    .figtree(16)
                    .foregroundStyle(Theme.secondary)
                    .padding(.horizontal, 4)
            } else {
                Text("Understood so far")
                    .figtree(16, weight: 500)
                    .foregroundStyle(Theme.secondary)
                    .padding(.horizontal, 4)
                FlowLayout(spacing: 10) {
                    ForEach(Array(drafts.enumerated()), id: \.offset) { _, draft in
                        DraftChip(draft: draft)
                    }
                }
            }

            AccentButton(title: drafts.count > 1 ? "Add \(drafts.count) entries" : "Add", systemImage: "checkmark") {
                submit(drafts)
            }
            .disabled(drafts.isEmpty)
            .opacity(drafts.isEmpty ? 0.5 : 1)

            Button { model.sheet = .newEntry(Date()) } label: {
                Text("Fill in each field instead")
                    .figtree(16, weight: 600)
                    .foregroundStyle(Theme.accentDeep)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Theme.gutter)
        .padding(.top, 20)
        .onAppear { fieldFocused = true }
    }

    private func submit(_ drafts: [EntryDraft]) {
        guard !drafts.isEmpty else { return }
        let text = typed
        Task {
            let interpreted = await EntryInterpreter().interpret(text)
            dismiss()
            model.receive(interpreted.isEmpty ? drafts : interpreted, from: text, source: .typed)
        }
    }
}
