import XCTest
@testable import KiraCore

final class SummaryAndSearchTests: XCTestCase {
    private var calendar: Calendar { TestClock.calendar }

    func testSampleMonthMatchesTheDesign() {
        let summary = MonthSummary.make(items: TestClock.sampleLedger, month: TestClock.now, now: TestClock.now, calendar: calendar)
        XCTAssertEqual(summary.spent, 214_630)
        XCTAssertEqual(summary.cameIn, 520_000)
        XCTAssertEqual(summary.left, 305_370)
        XCTAssertEqual(summary.daysInMonth, 30)
        XCTAssertEqual(summary.elapsedDays, 18)
        XCTAssertEqual(summary.daysLeft, 12)
        XCTAssertEqual(summary.dailySpent[17], 4_610)
        XCTAssertEqual(summary.dailySpent[0], 91_850)
        XCTAssertEqual(summary.perDayLeft, 25_447)
        XCTAssertEqual(summary.averagePerDayWithoutRent, 6_923)
        XCTAssertEqual(summary.categories.map(\.category), [.rent, .food, .groceries, .transport, .shopping, .bills])
        XCTAssertEqual(summary.total(for: .food), 48_640)
        XCTAssertEqual(summary.categories.first { $0.category == .food }?.count, 40)
        XCTAssertEqual(Int(((summary.spentShare ?? 0) * 100).rounded()), 41)
        XCTAssertEqual(summary.paceSentence(calendar: calendar),
                       "Spending slower than the month: 41% of income gone, 60% of September gone.")
    }

    func testFoodAgainstLastMonth() {
        let comparison = CategoryComparison.make(category: .food, items: TestClock.sampleLedger, month: TestClock.now, now: TestClock.now, calendar: calendar)
        XCTAssertEqual(comparison.thisPeriod, 48_640)
        XCTAssertEqual(comparison.lastPeriod, 54_740)
        XCTAssertEqual(comparison.sentence, "RM 61 less than August by this date")
    }

    func testSearchAnswerForGrab() {
        let summary = MonthSummary.make(items: [], month: TestClock.now, now: TestClock.now, calendar: calendar)
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: summary.start) ?? TestClock.now
        let grab = TestClock.sampleLedger.filter {
            $0.title.lowercased().contains("grab") && $0.date >= summary.start && $0.date < monthEnd
        }
        XCTAssertEqual(SearchAnswer.sentence(for: "grab", matches: grab),
                       "9 Grab rides this month, RM 146.60 in total. That\u{2019}s about RM 16 a ride.")
        XCTAssertNil(SearchAnswer.sentence(for: "g", matches: grab))
        XCTAssertNil(SearchAnswer.sentence(for: "nothing", matches: []))
    }

    func testSecondLunchQuestion() {
        let drafts = UtteranceParser(calendar: calendar).parse("lunch 12, grab 8.50, and Ali paid me back 20", now: TestClock.now)
        let questions = DuplicateChecker.questions(for: drafts, existing: TestClock.sampleLedger, calendar: calendar)
        XCTAssertEqual(questions.count, 1)
        XCTAssertEqual(questions.first?.draftID, drafts.first?.id)
        XCTAssertEqual(questions.first?.message, "You logged Nasi lemak + teh ais at 1:15 PM. Is this a second lunch?")
    }

    func testMoneyFormatting() {
        XCTAssertEqual(Money.format(214_630), "2,146.30")
        XCTAssertEqual(Money.format(500, currency: true), "RM 5.00")
        XCTAssertEqual(Money.format(2_000, signed: true), "+20.00")
        XCTAssertEqual(Money.format(-1_200), "\u{2212}12.00")
        XCTAssertEqual(Money.format(123_456_789), "1,234,567.89")
        XCTAssertEqual(Money.roundedRinggit(1_629), "RM 16")
        XCTAssertEqual(Money.sen(from: "12"), 1_200)
        XCTAssertEqual(Money.sen(from: "12.5"), 1_250)
        XCTAssertEqual(Money.sen(from: "RM 1,234.50"), 123_450)
        XCTAssertEqual(Money.sen(from: ".5"), 50)
        XCTAssertNil(Money.sen(from: "12.345"))
        XCTAssertNil(Money.sen(from: "abc"))
        XCTAssertNil(Money.sen(from: ""))
    }
}

final class ScreenshotParserTests: XCTestCase {
    private let lines = [
        "Transactions", "Wallet history",
        "7-Eleven", "4:10 PM", "-6.80",
        "Parking", "2:31 PM", "-3.00",
        "Reload from bank", "9:02 AM", "+50.00",
        "Bus fare", "17 Sep", "-2.50",
    ]

    func testWalletScreenshot() {
        let calendar = TestClock.calendar
        let existing = [LedgerItem(title: "Bus fare", amount: 250, isIncome: false, category: .transport, date: TestClock.date(2026, 9, 17, 8, 5))]
        let drafts = ScreenshotParser(calendar: calendar).parse(lines: lines, now: TestClock.now, existing: existing)

        XCTAssertEqual(drafts.map(\.title), ["7-Eleven", "Parking", "Reload from bank", "Bus fare"])
        XCTAssertEqual(drafts.map(\.amount), [680, 300, 5_000, 250])
        XCTAssertEqual(drafts.map(\.category), [.groceries, .transport, .other, .transport])
        XCTAssertEqual(drafts.map { TestClock.hourMinute($0.date) }, ["16:10", "14:31", "09:02", "12:00"])
        XCTAssertEqual(drafts.map(\.isTransfer), [false, false, true, false])
        XCTAssertEqual(drafts.map(\.isIncome), [false, false, false, false])
        XCTAssertEqual(drafts.map(\.isAlreadyLogged), [false, false, false, true])
        XCTAssertEqual(drafts.last.map { calendar.component(.day, from: $0.date) }, 17)
    }

    func testNameAndAmountOnOneLine() {
        let drafts = ScreenshotParser(calendar: TestClock.calendar).parse(
            lines: ["Today", "ZUS Coffee  -RM12.90", "8:42 AM", "Salary  +4,800.00", "9:00 AM", "Balance RM 1,234.56"],
            now: TestClock.now
        )
        XCTAssertEqual(drafts.map(\.title), ["ZUS Coffee", "Salary"])
        XCTAssertEqual(drafts.map(\.amount), [1_290, 480_000])
        XCTAssertEqual(drafts.map(\.isIncome), [false, true])
        XCTAssertEqual(drafts.map { TestClock.hourMinute($0.date) }, ["08:42", "09:00"])
    }
}
