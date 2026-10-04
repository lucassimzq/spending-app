import SwiftUI

/// The glass tab bar: Today, Month and Search, plus Add as the one prominent tab (the iOS 27 pattern).
/// On Search it turns into a back button and a search field, the way the system search tab does.
struct KiraTabBar: View {
    @Environment(AppModel.self) private var model
    @Namespace private var glassSpace
    @Namespace private var selectionSpace
    @FocusState private var searchFocused: Bool

    var body: some View {
        GlassEffectContainer(spacing: 10) {
            if model.tab == .search {
                searchBar
            } else {
                tabs
            }
        }
        .padding(.horizontal, Theme.gutter)
        .padding(.bottom, 4)
    }

    // MARK: Tabs

    private var tabs: some View {
        HStack(spacing: 2) {
            tabButton(.today)
            tabButton(.month)
            tabButton(.search)
            addButton
        }
        .padding(5)
        .glassEffect(.regular.interactive(), in: .capsule)
        .glassEffectID("bar", in: glassSpace)
    }

    private func tabButton(_ tab: AppModel.Tab) -> some View {
        let isSelected = model.tab == tab
        return Button { model.select(tab) } label: {
            VStack(spacing: 3) {
                TabIcon(tab: tab)
                    .frame(height: 24)
                Text(Self.title(for: tab))
                    .figtree(12, weight: 650, relativeTo: .caption2, maximumScale: 1.2)
            }
            .foregroundStyle(isSelected ? Theme.accentDeep : Theme.ink)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Theme.ink.opacity(0.07))
                        .matchedGeometryEffect(id: "selection", in: selectionSpace)
                }
            }
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Self.title(for: tab))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var addButton: some View {
        Button { model.sheet = .add } label: {
            VStack(spacing: 3) {
                Image(systemName: "plus")
                    .font(.system(size: 21, weight: .semibold))
                    .frame(height: 24)
                Text("Add")
                    .figtree(12, weight: 650, relativeTo: .caption2, maximumScale: 1.2)
            }
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(Theme.accentFill, in: .capsule)
            .shadow(color: Theme.accent.opacity(0.35), radius: 10, y: 4)
            .contentShape(.capsule)
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel("Add an entry")
    }

    // MARK: Search

    private var searchBar: some View {
        @Bindable var model = model
        return HStack(spacing: 10) {
            Button { model.leaveSearch() } label: {
                TabIcon(tab: model.tabBeforeSearch)
                    .foregroundStyle(Theme.ink)
                    .frame(width: 56, height: 56)
                    .contentShape(.circle)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .circle)
            .glassEffectID("back", in: glassSpace)
            .accessibilityLabel("Back to \(Self.title(for: model.tabBeforeSearch))")

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(Theme.secondary)
                    .accessibilityHidden(true)
                TextField("Search or ask", text: $model.searchText)
                    .figtree(19)
                    .foregroundStyle(Theme.ink)
                    .focused($searchFocused)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                if !model.searchText.isEmpty {
                    Button { model.searchText = "" } label: {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Theme.secondary)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.leading, 18)
            .padding(.trailing, 6)
            .frame(height: 56)
            .glassEffect(.regular.interactive(), in: .capsule)
            .glassEffectID("bar", in: glassSpace)
        }
        .task {
            try? await Task.sleep(for: .milliseconds(250))
            searchFocused = true
        }
    }

    static func title(for tab: AppModel.Tab) -> String {
        switch tab {
        case .today: return "Today"
        case .month: return "Month"
        case .search: return "Search"
        }
    }
}

/// The tab icons. Today is a piece of the timeline: a line with a dot on it.
struct TabIcon: View {
    let tab: AppModel.Tab

    var body: some View {
        switch tab {
        case .today:
            TimelineGlyph()
                .stroke(style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
                .frame(width: 12, height: 24)
        case .month:
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 20, weight: .medium))
        case .search:
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .medium))
        }
    }
}
