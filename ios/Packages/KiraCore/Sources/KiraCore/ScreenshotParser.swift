import Foundation

/// Reads transactions from the text lines of a banking or e-wallet screenshot (the app does the OCR).
///
/// Handles the common layouts: the name, time and amount on separate lines, the name and amount on one line,
/// or the time or date sharing the amount's line. A "+" amount is money in, unless it is a reload or top-up:
/// that only moves your own money, so it is marked as a transfer and left out of spending. Rows that match an
/// entry you already have are flagged so they can be skipped.
public struct ScreenshotParser: Sendable {
    public var calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    private static let amount = NSRegularExpression(
        constant: #"(?:([+\-−–])\s*)?(?:rm|myr)?\s*(\d{1,3}(?:,\d{3})*\.\d{2})(?!\d)"#,
        options: .caseInsensitive
    )
    private static let clock = NSRegularExpression(
        constant: #"(?<![\d:.])(\d{1,2}):(\d{2})(?!\d)(?:\s?(am|pm))?"#,
        options: .caseInsensitive
    )
    private static let monthPattern =
        "(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|june?|july?|aug(?:ust)?|sep(?:t(?:ember)?)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)"
    /// "17 Sep", "17 September 2026"
    private static let dayFirst = NSRegularExpression(
        constant: #"(?<![\d.])(\d{1,2})\s+"# + monthPattern + #"\.?(?![a-z])(?:\s+(\d{4}))?"#,
        options: .caseInsensitive
    )
    /// "Sep 17", "Sep 17, 2026"
    private static let monthFirst = NSRegularExpression(
        constant: #"(?<![a-z])"# + monthPattern + #"\.?\s+(\d{1,2})(?!\d)(?!\.\d)(?:,?\s+(\d{4}))?"#,
        options: .caseInsensitive
    )
    private static let months = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
    private static let headers: Set<String> = [
        "transactions", "transaction history", "history", "wallet history", "recent", "recent transactions",
        "balance", "available balance", "all", "spending", "activity", "today", "yesterday", "see all",
    ]

    public func parse(lines rawLines: [String], now: Date = Date(), existing: [LedgerItem] = []) -> [EntryDraft] {
        let lines = rawLines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        var drafts: [EntryDraft] = []
        var sectionDay: Date?

        for (index, line) in lines.enumerated() {
            let lower = line.lowercased()
            if lower == "today" { sectionDay = calendar.startOfDay(for: now); continue }
            if lower == "yesterday" {
                sectionDay = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))
                continue
            }
            guard let groups = Self.amount.firstMatchGroups(in: line), let number = groups[2],
                  let sen = Money.sen(from: number), sen > 0 else { continue }

            let sameLine = Self.cleanName(line)
            if Self.headers.contains(sameLine.lowercased()) { continue }   // "Balance RM 1,234.56"
            var name = sameLine
            var nameLine = index
            if !Self.looksLikeName(name) {
                name = ""
                var back = index - 1
                while back >= 0 && back >= index - 3 {
                    let candidate = lines[back]
                    if Self.amount.matches(candidate) { break }
                    let cleaned = Self.cleanName(candidate)
                    if Self.looksLikeName(cleaned) {
                        name = cleaned
                        nameLine = back
                        break
                    }
                    back -= 1
                }
            }
            guard !name.isEmpty else { continue }

            // The row's own time or date: on the amount line, between the name and the amount, on the name line,
            // or on the line just below the amount.
            var nearby = [index]
            if nameLine + 1 < index { nearby += Array((nameLine + 1)..<index) }
            if nameLine != index { nearby.append(nameLine) }
            if index + 1 < lines.count, !Self.amount.matches(lines[index + 1]) { nearby.append(index + 1) }
            var time: (hour: Int, minute: Int)?
            var rowDay: Date?
            for position in nearby {
                let candidate = lines[position]
                if time == nil, let clock = Self.findClock(in: candidate) { time = clock }
                if rowDay == nil, let day = findDay(in: candidate, now: now) { rowDay = day }
            }

            let baseDay = rowDay ?? sectionDay ?? calendar.startOfDay(for: now)
            let date: Date
            if let time {
                date = calendar.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: baseDay) ?? baseDay
            } else if calendar.isDate(baseDay, inSameDayAs: now) {
                date = now
            } else {
                date = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: baseDay) ?? baseDay
            }

            let lowerName = name.lowercased()
            let sign = groups[1]
            let isTransfer = Lexicon.transfer.matchesAny(lowerName)
            let isIncome = !isTransfer && (sign == "+" || Lexicon.income.matchesAny(lowerName))
            let category: EntryCategory = isIncome ? .moneyIn : (isTransfer ? .other : Lexicon.category(for: lowerName))
            let alreadyLogged = existing.contains { item in
                item.amount == sen
                    && abs(item.date.timeIntervalSince(date)) < 36 * 3600
                    && (item.title.lowercased().contains(lowerName) || lowerName.contains(item.title.lowercased()) || item.category == category)
            }
            drafts.append(EntryDraft(
                title: name,
                amount: sen,
                isIncome: isIncome,
                category: category,
                date: date,
                timeWasGuessed: time == nil,
                sourceText: line,
                isTransfer: isTransfer,
                isAlreadyLogged: alreadyLogged
            ))
        }
        return drafts
    }

    /// A line with amounts, times and dates taken out: "Grab · Sep 16" → "Grab", "4:10 PM  -6.80" → "".
    private static func cleanName(_ text: String) -> String {
        var cleaned = amount.replacingMatches(in: text, with: " ")
        cleaned = clock.replacingMatches(in: cleaned, with: " ")
        cleaned = dayFirst.replacingMatches(in: cleaned, with: " ")
        cleaned = monthFirst.replacingMatches(in: cleaned, with: " ")
        cleaned = cleaned.replacingOccurrences(of: #"\s{2,}"#, with: " ", options: .regularExpression)
        return cleaned.trimmingCharacters(in: CharacterSet.whitespaces.union(.punctuationCharacters))
    }

    private static func looksLikeName(_ text: String) -> Bool {
        let letters = text.filter { $0.isLetter }.count
        guard letters >= 2 else { return false }
        return !headers.contains(text.lowercased())
    }

    private static func findClock(in text: String) -> (hour: Int, minute: Int)? {
        guard let groups = clock.firstMatchGroups(in: text),
              var hour = groups[1].flatMap({ Int($0) }), let minute = groups[2].flatMap({ Int($0) }) else { return nil }
        let meridiem = groups[3]?.lowercased()
        if meridiem == "pm", hour < 12 { hour += 12 }
        if meridiem == "am", hour == 12 { hour = 0 }
        guard (0..<24).contains(hour), (0..<60).contains(minute) else { return nil }
        return (hour, minute)
    }

    private func findDay(in text: String, now: Date) -> Date? {
        let foundDay: Int?
        let foundMonth: String?
        let yearText: String?
        if let groups = Self.dayFirst.firstMatchGroups(in: text) {
            foundDay = groups[1].flatMap { Int($0) }
            foundMonth = groups[2]
            yearText = groups[3]
        } else if let groups = Self.monthFirst.firstMatchGroups(in: text) {
            foundMonth = groups[1]
            foundDay = groups[2].flatMap { Int($0) }
            yearText = groups[3]
        } else {
            return nil
        }
        guard let day = foundDay, (1...31).contains(day), let monthText = foundMonth,
              let monthIndex = Self.months.firstIndex(of: String(monthText.lowercased().prefix(3))) else { return nil }
        var components = DateComponents()
        components.day = day
        components.month = monthIndex + 1
        components.year = yearText.flatMap { Int($0) } ?? calendar.component(.year, from: now)
        guard var date = calendar.date(from: components) else { return nil }
        // "28 Dec" seen in early January belongs to last year.
        if yearText == nil, date > now.addingTimeInterval(86_400), let lastYear = calendar.date(byAdding: .year, value: -1, to: date) {
            date = lastYear
        }
        return calendar.startOfDay(for: date)
    }
}
