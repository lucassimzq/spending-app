import Foundation

/// Dates written the way the app talks: "1:15 PM", "Friday, 18 September", "Wed 16 Sep".
/// Uses a fixed English locale so sentences built from them read consistently.
public enum KiraFormat {
    public static func time(_ date: Date, calendar: Calendar = .current) -> String {
        formatter("h:mm a", calendar).string(from: date)
    }

    /// "September"
    public static func monthName(_ date: Date, calendar: Calendar = .current) -> String {
        formatter("MMMM", calendar).string(from: date)
    }

    /// "Friday, 18 September"
    public static func longDate(_ date: Date, calendar: Calendar = .current) -> String {
        formatter("EEEE, d MMMM", calendar).string(from: date)
    }

    /// "Wed 16 Sep"
    public static func shortDate(_ date: Date, calendar: Calendar = .current) -> String {
        formatter("EEE d MMM", calendar).string(from: date)
    }

    /// "Today", "Yesterday" or "Wednesday, 16 Sep"
    public static func dayTitle(_ date: Date, now: Date = Date(), calendar: Calendar = .current) -> String {
        if calendar.isDate(date, inSameDayAs: now) { return "Today" }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now), calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        }
        return formatter("EEEE, d MMM", calendar).string(from: date)
    }

    /// "1–18 Sep"
    public static func monthToDate(start: Date, through end: Date, calendar: Calendar = .current) -> String {
        let first = calendar.component(.day, from: start)
        let last = calendar.component(.day, from: end)
        return "\(first)\u{2013}\(last) " + formatter("MMM", calendar).string(from: end)
    }

    private static func formatter(_ format: String, _ calendar: Calendar) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = format
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }
}
