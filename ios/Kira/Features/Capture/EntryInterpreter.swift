import Foundation
import FoundationModels
import KiraCore

/// Turns what you said or typed into entries.
///
/// KiraCore's rules run first: they're instant, work offline on every iPhone, and handle Manglish ("tapau nasi ayam 8").
/// Apple's on-device model (Foundation Models) only steps in when the rules find nothing, or can't place an entry
/// in a category. It picks from Kira's own category list, so it can't invent new ones.
struct EntryInterpreter {
    var calendar: Calendar = .current

    func interpret(_ text: String, now: Date = Date()) async -> [EntryDraft] {
        var drafts = UtteranceParser(calendar: calendar).parse(text, now: now)
        guard OnDeviceModel.isAvailable else { return drafts }

        if drafts.isEmpty {
            return await OnDeviceModel.entries(in: text, now: now)
        }
        let unsure = drafts.indices.filter { !drafts[$0].isIncome && drafts[$0].category == .other }
        guard !unsure.isEmpty else { return drafts }
        let picks = await OnDeviceModel.categories(for: unsure.map { drafts[$0].title })
        for index in unsure {
            if let category = picks[drafts[index].title.lowercased()], category != .moneyIn {
                drafts[index].category = category
            }
        }
        return drafts
    }
}

/// Apple's on-device language model, used through guided generation into the types below.
enum OnDeviceModel {
    static var isAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability { return true }
        return false
    }

    private static let instructions = """
        You read short notes about money from someone in Malaysia and turn them into entries for a spending tracker. \
        Amounts are in ringgit (RM). People mix English and Malay, for example "tapau" (takeaway), "makan" (eat), \
        "minyak" (petrol), "gaji" (salary). Every separate amount is its own entry. Money that came in, such as \
        salary, a refund or someone paying them back, is income. Keep titles short, like "Lunch", "Grab" or \
        "Ali paid you back".
        """

    /// Reads entries from text the rules couldn't understand.
    static func entries(in text: String, now: Date) async -> [EntryDraft] {
        do {
            let session = LanguageModelSession(instructions: instructions)
            let response = try await session.respond(to: text, generating: SpokenEntries.self)
            return response.content.entries.compactMap { entry in
                let amount = Int((entry.ringgit * 100).rounded())
                let title = entry.title.trimmingCharacters(in: .whitespacesAndNewlines)
                guard amount > 0, !title.isEmpty else { return nil }
                let category = EntryCategory(rawValue: entry.category) ?? EntryCategory(loose: entry.category) ?? .other
                let isIncome = entry.isIncome || category == .moneyIn
                return EntryDraft(
                    title: title.prefix(1).uppercased() + title.dropFirst(),
                    amount: amount,
                    isIncome: isIncome,
                    category: isIncome ? .moneyIn : category,
                    date: now,
                    sourceText: text
                )
            }
        } catch {
            return []
        }
    }

    /// Picks a category for each title, keyed by the lowercased title.
    static func categories(for titles: [String]) async -> [String: EntryCategory] {
        do {
            let session = LanguageModelSession(instructions: instructions)
            let list = titles.map { "- \($0)" }.joined(separator: "\n")
            let prompt = "Pick the best category for each of these purchases:\n\(list)"
            let response = try await session.respond(to: prompt, generating: CategoryPicks.self)
            var picks: [String: EntryCategory] = [:]
            for pick in response.content.picks {
                if let category = EntryCategory(rawValue: pick.category) ?? EntryCategory(loose: pick.category) {
                    picks[pick.item.lowercased()] = category
                }
            }
            return picks
        } catch {
            return [:]
        }
    }
}

@Generable
struct SpokenEntries {
    @Guide(description: "Every separate amount of money in the note, in the order it was mentioned")
    var entries: [SpokenEntry]
}

@Generable
struct SpokenEntry {
    @Guide(description: "A short title for what it was, such as Lunch, Grab or Ali paid you back")
    var title: String
    @Guide(description: "The amount in Malaysian ringgit, such as 8.5 for RM 8.50")
    var ringgit: Double
    @Guide(description: "True only when money came in, such as salary, a refund or someone paying them back")
    var isIncome: Bool
    @Guide(description: "The category", .anyOf(["food", "groceries", "transport", "shopping", "bills", "rent", "other", "moneyIn"]))
    var category: String
}

@Generable
struct CategoryPicks {
    @Guide(description: "One pick for each purchase, in the same order")
    var picks: [CategoryPick]
}

@Generable
struct CategoryPick {
    @Guide(description: "The purchase exactly as it was given")
    var item: String
    @Guide(description: "The category", .anyOf(["food", "groceries", "transport", "shopping", "bills", "rent", "other"]))
    var category: String
}
