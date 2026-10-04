import Foundation
@testable import KiraCore

/// Tests run in Malaysian time against a fixed "now": Friday 18 September 2026, 7:45 PM.
enum TestClock {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kuala_Lumpur") ?? .current
        return calendar
    }()

    static let now = date(2026, 9, 18, 19, 45)

    static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? Date(timeIntervalSince1970: 0)
    }

    static func hourMinute(_ date: Date) -> String {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", parts.hour ?? 0, parts.minute ?? 0)
    }

    static var sampleLedger: [LedgerItem] { SampleData.ledger(now: now, calendar: calendar) }
}
