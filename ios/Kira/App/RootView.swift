import PhotosUI
import SwiftData
import SwiftUI
import KiraCore

/// The three tabs under one glass tab bar, plus everything presented over them: sheets, the listening screen,
/// the photo picker and the toast.
struct RootView: View {
    @Environment(AppModel.self) private var model
    @Query(sort: \LedgerEntry.date, order: .reverse) private var entries: [LedgerEntry]
    @State private var pickedScreenshot: PhotosPickerItem?

    var body: some View {
        @Bindable var model = model
        ZStack {
            page(.today) { TodayScreen() }
            page(.month) { MonthScreen() }
            page(.search) { SearchScreen() }
        }
        .background(Theme.background)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            KiraTabBar()
        }
        .overlay(alignment: .bottom) {
            if let toast = model.toast {
                ToastView(toast: toast)
                    .padding(.horizontal, Theme.gutter)
                    .padding(.bottom, 92)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay {
            if model.isListening {
                ListeningView()
                    .transition(.opacity)
            }
        }
        .overlay {
            if model.isReadingScreenshot {
                ReadingScreenshotView()
                    .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.3), value: model.isListening)
        .animation(.smooth(duration: 0.3), value: model.isReadingScreenshot)
        .sheet(item: $model.sheet) { sheet in
            sheetView(for: sheet)
        }
        .photosPicker(isPresented: $model.isPickingScreenshot, selection: $pickedScreenshot, matching: .screenshots)
        .onChange(of: pickedScreenshot) { _, item in
            guard let item else { return }
            pickedScreenshot = nil
            Task { await model.readScreenshot(item) }
        }
        .onOpenURL { model.handle($0) }
        .task { loadSampleMonthIfAsked() }
    }

    /// Keeps every tab alive (and its scroll position) while only the selected one is shown.
    private func page<Content: View>(_ tab: AppModel.Tab, @ViewBuilder content: () -> Content) -> some View {
        let isSelected = model.tab == tab
        return content()
            .opacity(isSelected ? 1 : 0)
            .allowsHitTesting(isSelected)
            .accessibilityHidden(!isSelected)
    }

    @ViewBuilder
    private func sheetView(for sheet: ActiveSheet) -> some View {
        switch sheet {
        case .add:
            AddSheet()
        case .review(let batch):
            ReviewSheet(batch: batch)
        case .edit(let id):
            if let entry = entries.first(where: { $0.uuid == id }) {
                EditEntrySheet(entry: entry)
            }
        case .newEntry(let day):
            EditEntrySheet(newEntryOn: day)
        case .screenshot(let batch):
            ScreenshotImportSheet(batch: batch)
        }
    }

    /// Launch with `-KiraSampleData YES` (for screenshots and demos) to start with the sample month.
    private func loadSampleMonthIfAsked() {
        guard UserDefaults.standard.bool(forKey: "KiraSampleData"), entries.isEmpty else { return }
        model.loadSampleMonth()
    }
}

/// Shown while a picked screenshot is being read.
private struct ReadingScreenshotView: View {
    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            VStack(spacing: 14) {
                ProgressView().controlSize(.large).tint(Theme.accentDeep)
                Text("Reading your screenshot…").figtree(18, weight: 550).foregroundStyle(Theme.ink)
            }
            .padding(28)
            .glassEffect(.regular, in: .rect(cornerRadius: 28))
        }
        .accessibilityElement(children: .combine)
    }
}
