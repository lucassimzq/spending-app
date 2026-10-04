import Foundation
import SwiftData

/// One store for the app, its widgets and its intents. It lives in the App Group container so all of them
/// read and write the same entries.
enum Persistence {
    /// Change this together with the App Group in project.yml when you use your own bundle IDs.
    static let appGroup = "group.com.example.kira"

    static let container: ModelContainer = makeContainer()

    private static func makeContainer() -> ModelContainer {
        let schema = Schema([LedgerEntry.self])
        // Builds without the App Group entitlement (unsigned simulator builds, previews) fall back to a private store.
        if FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) != nil {
            let shared = ModelConfiguration("Kira", schema: schema, groupContainer: .identifier(appGroup), cloudKitDatabase: .none)
            if let container = try? ModelContainer(for: schema, configurations: shared) { return container }
        }
        let local = ModelConfiguration("Kira", schema: schema, groupContainer: .none, cloudKitDatabase: .none)
        if let container = try? ModelContainer(for: schema, configurations: local) { return container }
        do {
            // Keeps the app usable for this session if the store on disk can't be opened.
            return try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true))
        } catch {
            fatalError("Kira couldn't create its entry store: \(error)")
        }
    }

    /// A store in memory with nothing in it, for previews and tests.
    static func inMemory() -> ModelContainer {
        let schema = Schema([LedgerEntry.self])
        do {
            return try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true))
        } catch {
            fatalError("Kira couldn't create an in-memory store: \(error)")
        }
    }
}
