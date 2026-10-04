import SwiftData
import SwiftUI
import UIKit
import KiraCore

/// Full screen while listening: your words appear as you speak, with amounts in tangerine, and every entry
/// the app picks out shows up as a chip. Tap the mic (or pause) to finish.
struct ListeningView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var capture = SpeechCapture()
    @State private var isWorking = false
    @State private var heardNothing = false
    @State private var glow = false

    var body: some View {
        let drafts = UtteranceParser().parse(capture.transcript)
        ZStack {
            backdrop
            VStack(alignment: .leading, spacing: 0) {
                topBar
                    .padding(.top, 8)
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        transcriptView
                        if !drafts.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Heard so far")
                                    .figtree(16, weight: 500)
                                    .foregroundStyle(Theme.secondary)
                                FlowLayout(spacing: 10) {
                                    // Parsed afresh on every change, so chips are keyed by position, not by their new IDs.
                                    ForEach(Array(drafts.enumerated()), id: \.offset) { _, draft in DraftChip(draft: draft) }
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                        Text(hint)
                            .figtree(17)
                            .foregroundStyle(Theme.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 28)
                    .animation(.snappy, value: drafts.count)
                }
                .scrollIndicators(.hidden)
                micButton
            }
            .padding(.horizontal, 20)
        }
        .task { await capture.start() }
        .task(id: capture.phase) { await finishAfterPause() }
        .onChange(of: capture.phase) { _, phase in
            // The recognizer can stop by itself (a long pause); treat that like tapping the mic.
            if phase == .done, !isWorking { Task { await finish() } }
        }
        .onDisappear { capture.cancel() }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { glow = true }
        }
    }

    // MARK: Parts

    private var backdrop: some View {
        ZStack {
            Rectangle().fill(.regularMaterial)
            Theme.background.opacity(0.55)
            // The tangerine edge glow that says "listening".
            RoundedRectangle(cornerRadius: 48)
                .strokeBorder(Theme.accent.opacity(glow ? 0.75 : 0.4), lineWidth: 26)
                .blur(radius: 26)
                .padding(-12)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private var topBar: some View {
        HStack {
            HStack(spacing: 10) {
                LevelBars(level: capture.level, isActive: capture.phase == .listening)
                Text(isWorking ? "Working it out" : "Listening")
                    .figtree(18, weight: 650)
                    .foregroundStyle(Theme.ink)
            }
            .padding(.horizontal, 18)
            .frame(height: 52)
            .glassEffect(.regular, in: .capsule)
            .accessibilityElement(children: .combine)

            Spacer()

            Button { cancel() } label: {
                Text("Cancel")
                    .figtree(18, weight: 550)
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal, 22)
                    .frame(height: 52)
                    .contentShape(.capsule)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .capsule)
        }
    }

    @ViewBuilder
    private var transcriptView: some View {
        if case .failed(let message) = capture.phase {
            VStack(alignment: .leading, spacing: 16) {
                Text(message)
                    .figtree(19, weight: 550)
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 12) {
                    GlassCapsuleButton(title: "Type it", systemImage: "keyboard") {
                        model.isListening = false
                        model.sheet = .add
                    }
                    GlassCapsuleButton(title: "Settings", systemImage: "gear") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        } else if capture.transcript.isEmpty {
            Text(heardNothing ? "I didn’t catch an amount. Try “lunch 12”." : "Say what you spent…")
                .fraunces(34, weight: 500, italic: true, wonky: true, relativeTo: .title)
                .foregroundStyle(Theme.secondary)
        } else {
            SpokenText(text: capture.transcript)
        }
    }

    private var micButton: some View {
        VStack(spacing: 14) {
            Button {
                Task { await finish() }
            } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 116, height: 116)
                    .background(Theme.accentFill, in: .circle)
                    .shadow(color: Theme.accent.opacity(0.5), radius: glow ? 30 : 16, y: 8)
                    .contentShape(.circle)
            }
            .buttonStyle(PressableStyle())
            .disabled(isWorking || capture.phase != .listening)
            .accessibilityLabel("Done")
            .accessibilityHint("Stops listening and shows what was heard")

            Text(isWorking ? "One moment…" : "Tap when you’re done")
                .figtree(18, weight: 550)
                .foregroundStyle(Theme.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 24)
        .padding(.top, 12)
    }

    private var hint: String {
        if capture.transcript.isEmpty { return "Say a few at once if you like: “lunch 12, grab 8.50, and Ali paid me back 20”." }
        return "Keep talking to add more. Tap the mic when you’re done."
    }

    // MARK: Actions

    private func finish() async {
        guard !isWorking else { return }
        isWorking = true
        let text = await capture.finish()
        let drafts = await EntryInterpreter().interpret(text)
        guard !drafts.isEmpty else {
            // Nothing to save: listen again instead of closing.
            isWorking = false
            heardNothing = true
            await capture.start()
            return
        }
        model.isListening = false
        model.receive(drafts, from: text, source: .voice)
    }

    /// Finishes by itself after three quiet seconds, once something has been said.
    private func finishAfterPause() async {
        guard capture.phase == .listening else { return }
        while !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(500))
            let quiet = Date().timeIntervalSince(capture.lastChange)
            let hasAmount = !UtteranceParser().parse(capture.transcript).isEmpty
            if hasAmount, quiet > 3, capture.phase == .listening, !isWorking {
                // Its own task: finishing changes the phase, which cancels this one.
                Task { await finish() }
                return
            }
        }
    }

    private func cancel() {
        capture.cancel()
        model.isListening = false
    }
}

/// What you said, in Fraunces italic, with the amounts picked out in tangerine.
struct SpokenText: View {
    let text: String

    var body: some View {
        styled
            .fraunces(34, weight: 560, italic: true, wonky: true, relativeTo: .title, maximumScale: 1.25)
            .foregroundStyle(Theme.ink)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(text)
    }

    private var styled: Text {
        var result = Text(verbatim: "")
        for (index, word) in text.split(separator: " ", omittingEmptySubsequences: true).enumerated() {
            let piece = (index == 0 ? "" : " ") + word
            let isAmount = word.contains { $0.isNumber }
            let segment = Text(verbatim: piece)
            result = Text("\(result)\(isAmount ? segment.foregroundStyle(Theme.accentDeep) : segment)")
        }
        return result
    }
}

/// Five bars that move with your voice.
struct LevelBars: View {
    let level: Double
    let isActive: Bool
    private let weights: [Double] = [0.55, 0.85, 1, 0.75, 0.6]

    var body: some View {
        HStack(spacing: 3) {
            ForEach(weights.indices, id: \.self) { index in
                Capsule()
                    .fill(Theme.accentDeep)
                    .frame(width: 4, height: 6 + 16 * (isActive ? max(level, 0.15) : 0.15) * weights[index])
            }
        }
        .frame(height: 24)
        .animation(.easeOut(duration: 0.12), value: level)
        .accessibilityHidden(true)
    }
}
