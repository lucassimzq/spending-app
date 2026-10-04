import SwiftData
import SwiftUI
import KiraCore

/// Today: the month's two numbers, then today on the timeline, then yesterday. Nothing else.
struct TodayScreen: View {
    @Environment(AppModel.self) private var model
    @Query(sort: \LedgerEntry.date, order: .reverse) private var entries: [LedgerEntry]
    @State private var showingCalendar = false
    @State private var openedDay: Date?

    var body: some View {
        NavigationStack {
            TimelineView(.everyMinute) { context in
                content(now: context.date)
            }
            .background(Theme.background)
            .toolbar { toolbar }
            .navigationDestination(item: $openedDay) { day in
                DayScreen(day: day)
            }
            .sheet(isPresented: $showingCalendar) {
                DayPickerSheet { day in openedDay = day }
            }
        }
    }

    private func content(now: Date) -> some View {
        let calendar = Calendar.current
        let summary = MonthSummary.make(items: entries.map(\.item), month: now, now: now, calendar: calendar)
        let today = entries.filter { calendar.isDate($0.date, inSameDayAs: now) }
        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        let yesterday = entries.filter { calendar.isDate($0.date, inSameDayAs: yesterdayDate) }
        let hasEarlier = entries.count > today.count + yesterday.count

        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenTitle(title: "Today", subtitle: KiraFormat.longDate(now, calendar: calendar))
                    .padding(.bottom, 22)

                if entries.isEmpty {
                    WelcomeCard(
                        onAdd: { model.sheet = .add },
                        onTrySample: { model.loadSampleMonth() }
                    )
                } else {
                    MonthSummaryCard(summary: summary, calendar: calendar) { model.select(.month) }
                        .padding(.bottom, 28)

                    SectionHeader(title: "Spent today", trailing: Money.format(spent(today), currency: true))
                        .padding(.bottom, 10)
                    DayTimeline(entries: today, now: now) { model.sheet = .edit($0.uuid) }

                    if !yesterday.isEmpty {
                        SectionHeader(title: "Yesterday", trailing: Money.format(spent(yesterday), currency: true))
                            .padding(.top, 26)
                            .padding(.bottom, 10)
                        DayTimeline(entries: yesterday) { model.sheet = .edit($0.uuid) }
                    }

                    if hasEarlier {
                        Button { model.select(.month) } label: {
                            HStack(spacing: 6) {
                                Text("Earlier this month is in Month")
                                    .figtree(16, weight: 550)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(Theme.accentDeep)
                            .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 22)
                    }
                }
            }
            .padding(.horizontal, Theme.gutter)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button { showingCalendar = true } label: {
                Image(systemName: "calendar")
            }
            .accessibilityLabel("Go to a day")
            Menu {
                Button { model.sheet = .newEntry(Date()) } label: {
                    Label("Fill in an entry", systemImage: "square.and.pencil")
                }
                Button { model.startListening() } label: {
                    Label("Log by voice", systemImage: "mic")
                }
                Divider()
                if model.hasSampleEntries {
                    Button(role: .destructive) { model.removeSampleEntries() } label: {
                        Label("Remove the sample month", systemImage: "trash")
                    }
                } else {
                    Button { model.loadSampleMonth() } label: {
                        Label("Load a sample month", systemImage: "wand.and.stars")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
            }
            .accessibilityLabel("More")
        }
    }

    private func spent(_ entries: [LedgerEntry]) -> Sen {
        entries.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
}

/// "September ›" with what went out and what came in. Opens the Month tab.
struct MonthSummaryCard: View {
    let summary: MonthSummary
    var calendar: Calendar = .current
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(KiraFormat.monthName(summary.start, calendar: calendar))
                        .figtree(17, weight: 500)
                        .foregroundStyle(Theme.secondary)
                    Spacer()
                    Chevron()
                }
                SpentAndCameIn(spent: summary.spent, cameIn: summary.cameIn)
            }
            .card()
        }
        .buttonStyle(PressableStyle())
        .accessibilityHint("Opens the month")
    }
}

/// What a new person sees: how to log, and a sample month to look around with.
private struct WelcomeCard: View {
    let onAdd: () -> Void
    let onTrySample: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nothing logged yet")
                .fraunces(28, weight: 640, wonky: true)
                .foregroundStyle(Theme.ink)
            Text("Tap Add and say it the way you'd text it: “lunch 12, grab 8.50”. You can also type it, share a screenshot, or say “Log in Kira” to Siri.")
                .figtree(17)
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            AccentButton(title: "Add your first entry", systemImage: "plus", action: onAdd)
            GlassCapsuleButton(title: "Look around with a sample month", systemImage: "wand.and.stars", action: onTrySample)
        }
        .card(padding: 22)
    }
}

/// One day's entries, opened from the calendar button.
struct DayScreen: View {
    let day: Date
    @Environment(AppModel.self) private var model
    @Query(sort: \LedgerEntry.date, order: .reverse) private var entries: [LedgerEntry]

    var body: some View {
        let calendar = Calendar.current
        let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: day) }
        let spent = dayEntries.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
        let cameIn = dayEntries.filter(\.isIncome).reduce(0) { $0 + $1.amount }
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenTitle(title: KiraFormat.dayTitle(day, calendar: calendar), subtitle: KiraFormat.longDate(day, calendar: calendar))
                    .padding(.bottom, 22)
                SpentAndCameIn(spent: spent, cameIn: cameIn)
                    .card()
                    .padding(.bottom, 28)
                SectionHeader(title: dayEntries.count == 1 ? "1 entry" : "\(dayEntries.count) entries")
                    .padding(.bottom, 10)
                if dayEntries.isEmpty {
                    Text("Nothing logged on this day.")
                        .figtree(16)
                        .foregroundStyle(Theme.secondary)
                        .padding(.horizontal, 4)
                } else {
                    DayTimeline(entries: dayEntries) { model.sheet = .edit($0.uuid) }
                }
                GlassCapsuleButton(title: "Add an entry on this day", systemImage: "plus") {
                    model.sheet = .newEntry(day)
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, Theme.gutter)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Theme.background)
    }
}

/// A calendar for jumping to a past day.
private struct DayPickerSheet: View {
    let onPick: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var day = Date()

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Go to a day", onClose: { dismiss() }, confirmLabel: "Open", onConfirm: {
                onPick(day)
                dismiss()
            })
            DatePicker("Day", selection: $day, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Theme.accentDeep)
                .padding(.horizontal, Theme.gutter)
            Spacer(minLength: 0)
        }
        .presentationDetents([.height(540), .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.background)
    }
}
