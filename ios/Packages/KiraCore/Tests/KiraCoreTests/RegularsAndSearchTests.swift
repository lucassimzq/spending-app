import XCTest
@testable import KiraCore

final class RegularsAndSearchTests: XCTestCase {
    private var calendar: Calendar { TestClock.calendar }

    private func daysAgo(_ days: Int) -> Date {
        let day = calendar.date(byAdding: .day, value: -days, to: TestClock.now) ?? TestClock.now
        return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: day) ?? day
    }

    private func spent(_ title: String, _ amount: Sen, _ category: EntryCategory, _ days: Int) -> LedgerItem {
        LedgerItem(title: title, amount: amount, isIncome: false, category: category, date: daysAgo(days))
    }

    func testRegularsAreTheThingsYouLogOften() {
        let items = [
            spent("Teh tarik", 280, .food, 1), spent("Teh tarik", 280, .food, 3), spent("Teh tarik", 300, .food, 5),
            spent("Grab", 1_200, .transport, 2), spent("Grab", 1_500, .transport, 4), spent("grab", 1_200, .transport, 10),
            spent("ZUS Coffee", 1_290, .food, 1),
            spent("Rent", 90_000, .rent, 17), spent("Rent", 90_000, .rent, 47),
            LedgerItem(title: "Salary", amount: 480_000, isIncome: true, category: .moneyIn, date: daysAgo(17)),
            LedgerItem(title: "Salary", amount: 480_000, isIncome: true, category: .moneyIn, date: daysAgo(47)),
            spent("Kopi", 480, .food, 65), spent("Kopi", 480, .food, 70),
        ]
        XCTAssertEqual(Regulars.top(from: items, now: TestClock.now, calendar: calendar), [
            Regular(title: "Teh tarik", amount: 280, category: .food, count: 3),
            Regular(title: "Grab", amount: 1_200, category: .transport, count: 3),
        ])
    }

    func testSearchQueryReadsPeriodsAndCategories() {
        let grab = SearchQuery("grab")
        XCTAssertEqual(grab.term, "grab")
        XCTAssertNil(grab.category)
        XCTAssertEqual(grab.period, .any)

        let food = SearchQuery("How much on food last month?")
        XCTAssertEqual(food.term, "")
        XCTAssertEqual(food.category, .food)
        XCTAssertEqual(food.period, .lastMonth)

        let coffee = SearchQuery("coffee this month")
        XCTAssertEqual(coffee.term, "coffee")
        XCTAssertEqual(coffee.period, .thisMonth)

        XCTAssertEqual(SearchQuery("Grab ride").term, "grab ride")
        XCTAssertTrue(SearchQuery("  ").isEmpty)
    }

    func testSearchingTheSampleMonth() {
        let ledger = TestClock.sampleLedger
        let now = TestClock.now

        let lastMonthFood = SearchQuery("food last month")
        let meals = ledger.filter { lastMonthFood.matches($0, now: now, calendar: calendar) }
        XCTAssertEqual(meals.count, 40)
        XCTAssertEqual(meals.reduce(0) { $0 + $1.amount }, 54_740)
        XCTAssertEqual(lastMonthFood.periodPhrase(for: meals, now: now, calendar: calendar), "last month")

        let grab = SearchQuery("grab")
        let rides = ledger.filter { grab.matches($0, now: now, calendar: calendar) }
        XCTAssertEqual(rides.count, 9)
        let period = grab.periodPhrase(for: rides, now: now, calendar: calendar)
        XCTAssertEqual(period, "this month")
        XCTAssertEqual(SearchAnswer.sentence(for: grab.displayText, matches: rides, period: period),
                       "9 Grab rides this month, RM 146.60 in total. That\u{2019}s about RM 16 a ride.")

        let kopi = SearchQuery("kopi")
        let cups = ledger.filter { kopi.matches($0, now: now, calendar: calendar) }
        XCTAssertEqual(cups.count, 10)
        XCTAssertEqual(kopi.periodPhrase(for: cups, now: now, calendar: calendar), "since August")
    }

    func testCategoryGuessForTitles() {
        XCTAssertEqual(EntryCategory.guess(from: "Grab ride home"), .transport)
        XCTAssertEqual(EntryCategory.guess(from: "Nasi lemak"), .food)
        XCTAssertEqual(EntryCategory.guess(from: "Movie"), .other)
        XCTAssertTrue(EntryCategory.soundsLikeIncome("Ali paid me back"))
        XCTAssertFalse(EntryCategory.soundsLikeIncome("Burger"))
    }
}

final class ScreenshotLayoutTests: XCTestCase {
    func testTimeOnTheAmountLine() {
        let drafts = ScreenshotParser(calendar: TestClock.calendar).parse(
            lines: ["7-Eleven", "4:10 PM  -6.80", "Parking  -3.00", "2:31 PM"],
            now: TestClock.now
        )
        XCTAssertEqual(drafts.map(\.title), ["7-Eleven", "Parking"])
        XCTAssertEqual(drafts.map { TestClock.hourMinute($0.date) }, ["16:10", "14:31"])
    }

    func testDatesNextToNamesAndAmounts() {
        let calendar = TestClock.calendar
        let drafts = ScreenshotParser(calendar: calendar).parse(
            lines: ["Bus fare", "17 Sep  -2.50", "Grab · Sep 16", "-12.00", "KK Mart 12.50"],
            now: TestClock.now
        )
        // "KK Mart 12.50" must not be read as 12 March.
        XCTAssertEqual(drafts.map(\.title), ["Bus fare", "Grab", "KK Mart"])
        XCTAssertEqual(drafts.map { calendar.component(.day, from: $0.date) }, [17, 16, 18])
        XCTAssertEqual(drafts.map(\.timeWasGuessed), [true, true, true])
    }
}
