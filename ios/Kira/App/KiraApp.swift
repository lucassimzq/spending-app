import SwiftUI

@main
struct KiraApp: App {
    @State private var model = AppModel.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                // Dark mode isn't designed yet, so the app stays light for now.
                .preferredColorScheme(.light)
        }
        .modelContainer(Persistence.container)
    }
}
