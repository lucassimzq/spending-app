import XCTest
@testable import KiraCore

final class UtteranceParserTests: XCTestCase {
    private let parser = UtteranceParser(calendar: TestClock.calendar)

    private struct Expected: Equatable, CustomStringConvertible {
        let title: String
        let amount: Sen
        let isIncome: Bool
        let category: EntryCategory
        let timeWasGuessed: Bool
        var description: String { "\(title) \(amount) income:\(isIncome) \(category.rawValue) guessed:\(timeWasGuessed)" }
    }

    private func check(_ text: String, _ expected: [Expected], file: StaticString = #filePath, line: UInt = #line) {
        let got = parser.parse(text, now: TestClock.now).map {
            Expected(title: $0.title, amount: $0.amount, isIncome: $0.isIncome, category: $0.category, timeWasGuessed: $0.timeWasGuessed)
        }
        XCTAssertEqual(got, expected, "“\(text)”", file: file, line: line)
    }

    private func e(_ title: String, _ amount: Sen, _ category: EntryCategory, income: Bool = false, guessed: Bool = false) -> Expected {
        Expected(title: title, amount: amount, isIncome: income, category: category, timeWasGuessed: guessed)
    }

    func testOneSentenceBecomesThreeEntries() {
        check("lunch 12, grab 8.50, and Ali paid me back 20", [
            e("Lunch", 1200, .food, guessed: true),
            e("Grab", 850, .transport),
            e("Ali paid you back", 2000, .moneyIn, income: true),
        ])
    }

    func testEverydaySentences() {
        check("I spent 5 ringgit on burger", [e("Burger", 500, .food)])
        check("I spend 5 ringgit on burger", [e("Burger", 500, .food)])
        check("nasi lemak and teh ais 9.50", [e("Nasi lemak and teh ais", 950, .food)])
        check("tapau nasi ayam 8", [e("Tapau nasi ayam", 800, .food)])
        check("RM12.90 ZUS Coffee", [e("ZUS Coffee", 1290, .food)])
        check("grabfood 23.40", [e("Grabfood", 2340, .food)])
        check("Grab ride home 18.70", [e("Grab ride home", 1870, .transport)])
        check("Lotus's 34.80", [e("Lotus's", 3480, .groceries)])
        check("unifi bill 129", [e("Unifi bill", 12900, .bills)])
        check("paid rent 900", [e("Rent", 90000, .rent)])
        check("teh tarik 2.80.", [e("Teh tarik", 280, .food)])
        check("makan 10", [e("Makan", 1000, .food)])
        check("kopi o 1.80", [e("Kopi o", 180, .food)])
        check("bought shoes for 120", [e("Shoes", 12000, .shopping)])
        check("netflix 54.90", [e("Netflix", 5490, .bills)])
        check("mr. diy 20", [e("Mr diy", 2000, .shopping)])
        check("spent 15 on grab", [e("Grab", 1500, .transport)])
    }

    func testAmountsInDifferentShapes() {
        check("eight fifty for parking", [e("Parking", 850, .transport)])
        check("twenty five ringgit for shopee", [e("Shopee", 2500, .shopping)])
        check("1.5k rent", [e("Rent", 150000, .rent)])
        check("12 ringgit 50 for lunch", [e("Lunch", 1250, .food, guessed: true)])
        check("2 coffees 9.80", [e("2 coffees", 980, .food)])
        check("coffee at 12.50", [e("Coffee", 1250, .food)])
    }

    func testSeveralEntriesInOneGo() {
        check("dinner 25 and movie 18", [e("Dinner", 2500, .food), e("Movie", 1800, .other)])
        check("breakfast rm 6.50 then lunch 12", [e("Breakfast", 650, .food, guessed: true), e("Lunch", 1200, .food, guessed: true)])
        check("toll 2.10 and petrol 50", [e("Toll", 210, .transport), e("Petrol", 5000, .transport)])
        check("lunch 12. grab 8", [e("Lunch", 1200, .food, guessed: true), e("Grab", 800, .transport)])
    }

    func testMoneyIn() {
        check("salary 4800", [e("Salary", 480000, .moneyIn, income: true)])
        check("got 400 from freelance", [e("From freelance", 40000, .moneyIn, income: true)])
        check("cashback 5", [e("Cashback", 500, .moneyIn, income: true)])
        check("refund 30 from shopee", [e("Refund from shopee", 3000, .moneyIn, income: true)])
        check("Ali paid me back RM20 for the movie", [e("Ali paid you back for the movie", 2000, .moneyIn, income: true)])
    }

    func testNothingToLog() {
        check("no numbers here", [])
        check("", [])
    }

    func testTimes() {
        let lunch = parser.parse("lunch 12", now: TestClock.now)
        XCTAssertEqual(lunch.first.map { TestClock.hourMinute($0.date) }, "13:00")
        XCTAssertEqual(lunch.first?.guessedFrom, "lunch")

        let coffee = parser.parse("coffee at 3pm 14", now: TestClock.now)
        XCTAssertEqual(coffee.first.map { TestClock.hourMinute($0.date) }, "15:00")
        XCTAssertEqual(coffee.first?.timeWasGuessed, false)

        let petrol = parser.parse("petrol 60 yesterday", now: TestClock.now)
        XCTAssertEqual(petrol.first?.timeWasGuessed, true)
        XCTAssertEqual(petrol.first.map { TestClock.calendar.component(.day, from: $0.date) }, 17)

        // Dinner hasn't happened yet at 7:45 PM, so it is logged as "now".
        let dinner = parser.parse("dinner 25", now: TestClock.now)
        XCTAssertEqual(dinner.first?.date, TestClock.now)
        XCTAssertEqual(dinner.first?.timeWasGuessed, false)
    }
}
