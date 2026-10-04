import Foundation

/// Turns what someone said or typed into entries, without any network or model:
/// "lunch 12, grab 8.50, and Ali paid me back 20" → Lunch 12.00 · Grab 8.50 · Ali paid you back +20.00.
///
/// The steps: split into words, cut the sentence into clauses (one per amount), pick the amount in each
/// clause, then work out spent or received, the category, the time and a short title.
public struct UtteranceParser: Sendable {
    public var calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public func parse(_ text: String, now: Date = Date()) -> [EntryDraft] {
        let tokens = Tokenizer.tokenize(text)
        var drafts: [EntryDraft] = []
        for clause in ClauseSplitter.split(tokens) {
            let candidates = AmountFinder.find(in: clause)
            guard let best = AmountFinder.choose(candidates), best.sen > 0 else { continue }
            let lowered = clause.map(\.lower).joined(separator: " ")
            let isIncome = best.hasPlusSign || Lexicon.income.matchesAny(lowered)
            let category: EntryCategory = isIncome ? .moneyIn : Lexicon.category(for: lowered)
            let time = TimeGuesser(calendar: calendar).guess(in: lowered, now: now)
            var title = TitleMaker.title(from: clause, removing: Set(best.span), isIncome: isIncome)
            if title.isEmpty {
                title = category == .other ? "Expense" : category.name
            }
            drafts.append(EntryDraft(
                title: title,
                amount: best.sen,
                isIncome: isIncome,
                category: category,
                date: time.date,
                timeWasGuessed: time.wasGuessed,
                guessedFrom: time.word,
                sourceText: clause.map(\.raw).joined(separator: " ")
            ))
        }
        return drafts
    }
}

// MARK: - Words

struct Token: Equatable {
    let raw: String
    let lower: String

    static let clauseBreak = Token(raw: "|", lower: "|")
    var isClauseBreak: Bool { lower == "|" }
}

enum Tokenizer {
    private static let leadingStrip: Set<Character> = ["(", "\"", "\u{201C}", "\u{2018}"]
    private static let trailingStrip: Set<Character> = [",", ";", ":", "!", "?", ".", ")", "\"", "\u{201D}", "\u{2019}"]
    private static let breakers: Set<Character> = [",", ";", ":", "!", "?", "."]

    /// Splits on whitespace and strips surrounding punctuation. A word ending in , ; : ! ? or . ends a clause.
    /// Dots inside a word survive, so "8.50" and "mr.diy" stay whole.
    static func tokenize(_ text: String) -> [Token] {
        let normalized = text
            .replacingOccurrences(of: "\u{2019}", with: "'")
            .replacingOccurrences(of: "\u{2013}", with: "-")
            .replacingOccurrences(of: "\u{2014}", with: "-")
            .replacingOccurrences(of: "\u{2212}", with: "-")
        var tokens: [Token] = []
        for piece in normalized.split(whereSeparator: { $0.isWhitespace }) {
            var core = piece
            while let first = core.first, leadingStrip.contains(first) {
                core = core.dropFirst()
            }
            var breaks = false
            while let last = core.last, trailingStrip.contains(last) {
                if breakers.contains(last) { breaks = true }
                core = core.dropLast()
            }
            if !core.isEmpty {
                tokens.append(Token(raw: String(core), lower: core.lowercased()))
            }
            if breaks {
                tokens.append(.clauseBreak)
            }
        }
        return tokens
    }
}

// MARK: - Clauses

enum ClauseSplitter {
    /// Breaks at punctuation, and at "and/then/plus…" once the current clause already has an amount.
    /// A clause without an amount ("nasi lemak" in "nasi lemak and teh ais 9.50") joins the next one.
    static func split(_ tokens: [Token]) -> [[Token]] {
        var clauses: [[Token]] = []
        var current: [Token] = []
        for token in tokens {
            if token.isClauseBreak {
                if !current.isEmpty { clauses.append(current) }
                current = []
                continue
            }
            if Lexicon.connectors.contains(token.lower), !current.isEmpty, !AmountFinder.find(in: current).isEmpty {
                clauses.append(current)
                current = []
                continue
            }
            current.append(token)
        }
        if !current.isEmpty { clauses.append(current) }

        var merged: [[Token]] = []
        var pending: [Token] = []
        for clause in clauses {
            if AmountFinder.find(in: clause).isEmpty {
                pending += clause
                continue
            }
            merged.append(pending + clause)
            pending = []
        }
        if !pending.isEmpty, !merged.isEmpty {
            merged[merged.count - 1] += pending
        }
        return merged
    }
}

// MARK: - Amounts

struct AmountCandidate: Equatable {
    var sen: Sen
    var hasCurrency: Bool
    var hasDecimal: Bool
    /// Token positions that make up the amount, so the title can leave them out.
    var span: [Int]
    var hasPlusSign: Bool
    var fromWords: Bool
}

enum AmountFinder {
    private static let numberToken = NSRegularExpression(
        constant: #"^(rm|\+|-)?(\d{1,3}(?:,\d{3})+|\d+)(?:\.(\d{1,2}))?(k)?(rm|ringgit)?$"#
    )
    private static let oneOrTwoDigits = NSRegularExpression(constant: #"^\d{1,2}$"#)

    struct ParsedNumber {
        var sen: Sen
        var hasCurrency: Bool
        var hasDecimal: Bool
        var prefix: String?
    }

    /// "12", "8.50", "rm12.90", "1.5k", "1,200", "+20", "12ringgit".
    static func parseNumberToken(_ lower: String) -> ParsedNumber? {
        guard let groups = numberToken.firstMatchGroups(in: lower), let wholeText = groups[2] else { return nil }
        guard let whole = Int(wholeText.replacingOccurrences(of: ",", with: "")), whole < 10_000_000 else { return nil }
        var sen = whole * 100
        if let fraction = groups[3] {
            sen += Int(fraction.padding(toLength: 2, withPad: "0", startingAt: 0)) ?? 0
        }
        if groups[4] != nil { sen *= 1000 }
        let prefix = groups[1]
        return ParsedNumber(sen: sen, hasCurrency: prefix == "rm" || groups[5] != nil, hasDecimal: groups[3] != nil, prefix: prefix)
    }

    static func find(in tokens: [Token]) -> [AmountCandidate] {
        var found: [AmountCandidate] = []
        let count = tokens.count
        var index = 0
        while index < count {
            let word = tokens[index].lower

            if let parsed = parseNumberToken(word) {
                var sen = parsed.sen
                var hasCurrency = parsed.hasCurrency
                var hasDecimal = parsed.hasDecimal
                var span = [index]
                if index > 0, Lexicon.currencyWords.contains(tokens[index - 1].lower) {
                    hasCurrency = true
                    span.insert(index - 1, at: 0)
                }
                let next = index + 1
                if next < count, Lexicon.currencyWords.contains(tokens[next].lower) {
                    // "12 ringgit" or "12 ringgit 50"
                    hasCurrency = true
                    span.append(next)
                    if next + 1 < count, !hasDecimal, oneOrTwoDigits.matches(tokens[next + 1].lower),
                       let extra = Int(tokens[next + 1].lower) {
                        sen += tokens[next + 1].lower.count == 2 ? extra : extra * 10
                        span.append(next + 1)
                        hasDecimal = true
                    }
                } else if next < count, tokens[next].lower == "sen", !hasDecimal {
                    // "50 sen"
                    sen /= 100
                    hasCurrency = true
                    hasDecimal = true
                    span.append(next)
                }
                found.append(AmountCandidate(sen: sen, hasCurrency: hasCurrency, hasDecimal: hasDecimal, span: span,
                                             hasPlusSign: parsed.prefix == "+", fromWords: false))
                index = (span.max() ?? index) + 1
                continue
            }

            if let first = Lexicon.numberWords[word] {
                // "five", "twenty five", "eight fifty", "twelve point five"
                var value = first
                var span = [index]
                var next = index + 1
                if value >= 20, value % 10 == 0, next < count, let unit = Lexicon.numberWords[tokens[next].lower], unit < 10 {
                    value += unit
                    span.append(next)
                    next += 1
                }
                var sen = value * 100
                var hasDecimal = false
                if next + 1 < count, tokens[next].lower == "point", let decimal = Lexicon.numberWords[tokens[next + 1].lower] {
                    sen += decimal < 10 ? decimal * 10 : decimal
                    span += [next, next + 1]
                    next += 2
                    hasDecimal = true
                } else if value < 20, next < count, Lexicon.centsWords.contains(tokens[next].lower),
                          let cents = Lexicon.numberWords[tokens[next].lower] {
                    sen += cents
                    span.append(next)
                    next += 1
                    hasDecimal = true
                }
                var hasCurrency = false
                if index > 0, Lexicon.currencyWords.contains(tokens[index - 1].lower) {
                    hasCurrency = true
                    span.insert(index - 1, at: 0)
                }
                if next < count, Lexicon.currencyWords.contains(tokens[next].lower) {
                    hasCurrency = true
                    span.append(next)
                }
                found.append(AmountCandidate(sen: sen, hasCurrency: hasCurrency, hasDecimal: hasDecimal, span: span,
                                             hasPlusSign: false, fromWords: true))
                index = (span.max() ?? index) + 1
                continue
            }

            index += 1
        }
        return found
    }

    /// Prefers an amount marked as money ("RM 12", "12 ringgit"), then one with cents, then the last digits.
    /// So "2 coffees 9.80" is 9.80, not 2.
    static func choose(_ candidates: [AmountCandidate]) -> AmountCandidate? {
        if let marked = candidates.last(where: { $0.hasCurrency }) { return marked }
        if let withCents = candidates.last(where: { $0.hasDecimal }) { return withCents }
        return candidates.last(where: { !$0.fromWords }) ?? candidates.last
    }
}

// MARK: - Time

struct TimeGuess: Equatable {
    var date: Date
    var wasGuessed: Bool
    var word: String?
}

struct TimeGuesser {
    let calendar: Calendar

    private static let yesterday = PhraseMatcher(["yesterday", "semalam"])
    /// "3pm", "3 pm", "3:30pm", "3.30 pm"
    private static let clockWithMeridiem = NSRegularExpression(constant: #"(?<![\d.])(\d{1,2})(?:[:.](\d{2}))?\s?(am|pm)(?![a-z])"#)
    /// "at 14:30". A dot is not accepted here, so "coffee at 12.50" stays an amount.
    private static let clock24 = NSRegularExpression(constant: #"(?<![\d.])at (\d{1,2}):(\d{2})(?!\d)"#)
    private static let meals: [(word: String, hour: Int, minute: Int, matcher: PhraseMatcher)] = [
        ("breakfast", 8, 0), ("sarapan", 8, 0), ("brunch", 11, 0), ("lunch", 13, 0), ("makan tengahari", 13, 0),
        ("tea time", 16, 0), ("dinner", 20, 0), ("makan malam", 20, 0), ("supper", 23, 0),
        ("this morning", 9, 0), ("pagi tadi", 9, 0), ("this afternoon", 14, 0), ("tonight", 20, 0),
    ].map { (word: $0.0, hour: $0.1, minute: $0.2, matcher: PhraseMatcher([$0.0])) }

    func guess(in lowered: String, now: Date) -> TimeGuess {
        let isYesterday = Self.yesterday.matchesAny(lowered)
        let day = isYesterday ? (calendar.date(byAdding: .day, value: -1, to: now) ?? now) : now

        func at(_ hour: Int, _ minute: Int) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
        }

        if let groups = Self.clockWithMeridiem.firstMatchGroups(in: lowered),
           var hour = groups[1].flatMap({ Int($0) }) {
            let minute = groups[2].flatMap { Int($0) } ?? 0
            let meridiem = groups[3]
            if meridiem == "pm", hour < 12 { hour += 12 }
            if meridiem == "am", hour == 12 { hour = 0 }
            if (0..<24).contains(hour), (0..<60).contains(minute) {
                return TimeGuess(date: at(hour, minute), wasGuessed: false, word: nil)
            }
        }
        if let groups = Self.clock24.firstMatchGroups(in: lowered),
           let hour = groups[1].flatMap({ Int($0) }), let minute = groups[2].flatMap({ Int($0) }),
           (0..<24).contains(hour), (0..<60).contains(minute) {
            return TimeGuess(date: at(hour, minute), wasGuessed: false, word: nil)
        }
        for meal in Self.meals where meal.matcher.matchesAny(lowered) {
            let guessed = at(meal.hour, meal.minute)
            if guessed > now {
                // Dinner later today hasn't happened yet, so it is probably happening now.
                return TimeGuess(date: now, wasGuessed: false, word: meal.word)
            }
            return TimeGuess(date: guessed, wasGuessed: true, word: meal.word)
        }
        if isYesterday {
            return TimeGuess(date: at(12, 0), wasGuessed: true, word: "yesterday")
        }
        return TimeGuess(date: now, wasGuessed: false, word: nil)
    }
}

// MARK: - Titles

enum TitleMaker {
    private static let timeWord = NSRegularExpression(constant: #"^(\d{1,2}([:.]\d{2})?(am|pm)|\d{1,2}:\d{2}|am|pm)$"#)
    private static let rewrites: [(NSRegularExpression, String)] = [
        (NSRegularExpression(constant: #"\bpaid me back\b"#, options: .caseInsensitive), "paid you back"),
        (NSRegularExpression(constant: #"\bpaid me\b"#, options: .caseInsensitive), "paid you"),
        (NSRegularExpression(constant: #"\bsent me\b"#, options: .caseInsensitive), "sent you"),
        (NSRegularExpression(constant: #"\bgave me\b"#, options: .caseInsensitive), "gave you"),
        (NSRegularExpression(constant: #"^from\s+"#, options: .caseInsensitive), "From "),
    ]
    private static let spaces = NSRegularExpression(constant: #"\s+"#)

    /// What's left of the clause once the amount, currency words, times and filler words are gone.
    /// Money in is retold from your side: "Ali paid me back" becomes "Ali paid you back".
    static func title(from clause: [Token], removing span: Set<Int>, isIncome: Bool) -> String {
        var kept = clause.enumerated()
            .filter { !span.contains($0.offset) && !Lexicon.currencyWords.contains($0.element.lower) && $0.element.lower != "sen" }
            .map(\.element)
            .filter { !timeWord.matches($0.lower) }
        while let first = kept.first, Lexicon.leadingFiller.contains(first.lower) { kept.removeFirst() }
        while let last = kept.last, Lexicon.trailingFiller.contains(last.lower) { kept.removeLast() }

        var title = kept.map(\.raw).joined(separator: " ")
        if isIncome {
            for (pattern, replacement) in rewrites {
                title = pattern.replacingMatches(in: title, with: replacement)
            }
        }
        title = spaces.replacingMatches(in: title, with: " ")
            .trimmingCharacters(in: CharacterSet(charactersIn: " ,.-"))
        guard let first = title.first else { return "" }
        return first.uppercased() + title.dropFirst()
    }
}
