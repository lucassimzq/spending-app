import Foundation

extension NSRegularExpression {
    /// Compiles a pattern that is known to be valid. Patterns in this package are constants covered by tests.
    convenience init(constant pattern: String, options: NSRegularExpression.Options = []) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Invalid regular expression \(pattern): \(error)")
        }
    }

    /// Capture groups of the first match (index 0 is the whole match), or nil when nothing matches.
    func firstMatchGroups(in text: String) -> [String?]? {
        let range = NSRange(text.startIndex..., in: text)
        guard let match = firstMatch(in: text, options: [], range: range) else { return nil }
        return (0..<match.numberOfRanges).map { index in
            let nsRange = match.range(at: index)
            guard nsRange.location != NSNotFound, let swiftRange = Range(nsRange, in: text) else { return nil }
            return String(text[swiftRange])
        }
    }

    func matches(_ text: String) -> Bool {
        firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) != nil
    }

    func replacingMatches(in text: String, with template: String) -> String {
        stringByReplacingMatches(in: text, options: [], range: NSRange(text.startIndex..., in: text), withTemplate: template)
    }
}

/// Finds whole words or phrases in lowercased text, allowing a plural "s"/"es" ("coffees" matches "coffee").
struct PhraseMatcher {
    private let phrases: [(phrase: String, regex: NSRegularExpression)]

    init(_ phrases: [String]) {
        self.phrases = phrases.map { phrase in
            let pattern = "(?<![a-z0-9])" + NSRegularExpression.escapedPattern(for: phrase) + "(?:s|es)?(?![a-z0-9])"
            return (phrase, NSRegularExpression(constant: pattern))
        }
    }

    /// The first phrase (in list order) found in `text`.
    func firstMatch(in text: String) -> String? {
        phrases.first { $0.regex.matches(text) }?.phrase
    }

    func matchesAny(_ text: String) -> Bool {
        firstMatch(in: text) != nil
    }
}
