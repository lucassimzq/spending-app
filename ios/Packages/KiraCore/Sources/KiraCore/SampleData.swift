import Foundation

/// A realistic month for demos, previews and screenshots. When "today" is the 18th it matches the design exactly:
/// RM 2,146.30 out, RM 5,200.00 in, 41% of income spent, 9 Grab rides worth RM 146.60, and food RM 61 under last month.
public enum SampleData {
    public struct Item: Sendable {
        public let daysAgo: Int
        public let hour: Int
        public let minute: Int
        public let title: String
        public let amount: Sen
        public let category: EntryCategory

        public init(daysAgo: Int, hour: Int, minute: Int, title: String, amount: Sen, category: EntryCategory) {
            self.daysAgo = daysAgo
            self.hour = hour
            self.minute = minute
            self.title = title
            self.amount = amount
            self.category = category
        }
    }

    /// The 18 days up to and including today. `daysAgo: 0` is today.
    public static let items: [Item] = [
        .init(daysAgo: 17, hour: 10, minute: 0, title: "Rent", amount: 90000, category: .rent),
        .init(daysAgo: 17, hour: 8, minute: 20, title: "Roti canai + teh", amount: 650, category: .food),
        .init(daysAgo: 17, hour: 13, minute: 10, title: "Chicken rice", amount: 1200, category: .food),
        .init(daysAgo: 17, hour: 9, minute: 0, title: "Salary", amount: 480000, category: .moneyIn),
        .init(daysAgo: 16, hour: 8, minute: 35, title: "Grab", amount: 950, category: .transport),
        .init(daysAgo: 16, hour: 12, minute: 50, title: "Nasi lemak", amount: 980, category: .food),
        .init(daysAgo: 16, hour: 20, minute: 30, title: "Mamak dinner", amount: 1890, category: .food),
        .init(daysAgo: 15, hour: 8, minute: 15, title: "Kopi + kaya toast", amount: 860, category: .food),
        .init(daysAgo: 15, hour: 13, minute: 0, title: "Economy rice", amount: 1820, category: .food),
        .init(daysAgo: 14, hour: 18, minute: 40, title: "Grab", amount: 2240, category: .transport),
        .init(daysAgo: 14, hour: 9, minute: 0, title: "Teh tarik", amount: 280, category: .food),
        .init(daysAgo: 14, hour: 13, minute: 20, title: "Laksa", amount: 1590, category: .food),
        .init(daysAgo: 14, hour: 20, minute: 10, title: "Dinner with family", amount: 2320, category: .food),
        .init(daysAgo: 13, hour: 22, minute: 5, title: "Shopee", amount: 6910, category: .shopping),
        .init(daysAgo: 13, hour: 11, minute: 30, title: "Lotus's", amount: 4800, category: .groceries),
        .init(daysAgo: 13, hour: 11, minute: 55, title: "Fruit stall", amount: 2430, category: .groceries),
        .init(daysAgo: 13, hour: 9, minute: 10, title: "Breakfast", amount: 900, category: .food),
        .init(daysAgo: 13, hour: 13, minute: 5, title: "Lunch", amount: 1450, category: .food),
        .init(daysAgo: 13, hour: 19, minute: 45, title: "Steamboat", amount: 2150, category: .food),
        .init(daysAgo: 12, hour: 10, minute: 20, title: "99 Speedmart", amount: 3180, category: .groceries),
        .init(daysAgo: 12, hour: 8, minute: 30, title: "Pasar pagi", amount: 2240, category: .groceries),
        .init(daysAgo: 12, hour: 8, minute: 10, title: "Kopi", amount: 480, category: .food),
        .init(daysAgo: 12, hour: 12, minute: 40, title: "Chicken rice", amount: 1290, category: .food),
        .init(daysAgo: 12, hour: 19, minute: 30, title: "Pizza", amount: 1700, category: .food),
        .init(daysAgo: 11, hour: 9, minute: 0, title: "Roti canai", amount: 520, category: .food),
        .init(daysAgo: 11, hour: 13, minute: 15, title: "Nasi kandar", amount: 1620, category: .food),
        .init(daysAgo: 10, hour: 9, minute: 5, title: "Grab", amount: 1560, category: .transport),
        .init(daysAgo: 10, hour: 8, minute: 40, title: "ZUS Coffee", amount: 1290, category: .food),
        .init(daysAgo: 10, hour: 12, minute: 55, title: "Economy rice", amount: 1000, category: .food),
        .init(daysAgo: 10, hour: 20, minute: 15, title: "Satay", amount: 860, category: .food),
        .init(daysAgo: 9, hour: 9, minute: 15, title: "Teh tarik", amount: 280, category: .food),
        .init(daysAgo: 9, hour: 13, minute: 0, title: "Char kuey teow", amount: 1700, category: .food),
        .init(daysAgo: 8, hour: 10, minute: 0, title: "Unifi", amount: 8900, category: .bills),
        .init(daysAgo: 8, hour: 10, minute: 5, title: "Phone bill", amount: 3500, category: .bills),
        .init(daysAgo: 8, hour: 10, minute: 10, title: "Water bill", amount: 2540, category: .bills),
        .init(daysAgo: 8, hour: 16, minute: 30, title: "Kuih", amount: 690, category: .food),
        .init(daysAgo: 7, hour: 19, minute: 55, title: "Grab", amount: 1400, category: .transport),
        .init(daysAgo: 7, hour: 8, minute: 50, title: "Nasi lemak", amount: 820, category: .food),
        .init(daysAgo: 7, hour: 15, minute: 20, title: "Bubble tea", amount: 1140, category: .food),
        .init(daysAgo: 6, hour: 16, minute: 10, title: "Jaya Grocer", amount: 3140, category: .groceries),
        .init(daysAgo: 6, hour: 11, minute: 30, title: "Grab", amount: 1200, category: .transport),
        .init(daysAgo: 6, hour: 10, minute: 30, title: "Dim sum", amount: 1650, category: .food),
        .init(daysAgo: 6, hour: 15, minute: 0, title: "Kopi", amount: 1200, category: .food),
        .init(daysAgo: 5, hour: 15, minute: 40, title: "Uniqlo", amount: 8990, category: .shopping),
        .init(daysAgo: 5, hour: 15, minute: 5, title: "Parking", amount: 600, category: .transport),
        .init(daysAgo: 5, hour: 9, minute: 0, title: "Kopi + kaya toast", amount: 860, category: .food),
        .init(daysAgo: 5, hour: 20, minute: 0, title: "Dinner with friends", amount: 3250, category: .food),
        .init(daysAgo: 5, hour: 13, minute: 10, title: "Laksa", amount: 2140, category: .food),
        .init(daysAgo: 4, hour: 18, minute: 5, title: "Grab", amount: 820, category: .transport),
        .init(daysAgo: 4, hour: 8, minute: 45, title: "Nasi lemak", amount: 650, category: .food),
        .init(daysAgo: 4, hour: 13, minute: 0, title: "Chicken rice", amount: 1000, category: .food),
        .init(daysAgo: 3, hour: 22, minute: 12, title: "Grab", amount: 3420, category: .transport),
        .init(daysAgo: 3, hour: 12, minute: 45, title: "Economy rice", amount: 1110, category: .food),
        .init(daysAgo: 3, hour: 16, minute: 0, title: "Teh tarik", amount: 700, category: .food),
        .init(daysAgo: 2, hour: 17, minute: 30, title: "Jaya Grocer", amount: 4620, category: .groceries),
        .init(daysAgo: 2, hour: 8, minute: 40, title: "Grab", amount: 1200, category: .transport),
        .init(daysAgo: 2, hour: 8, minute: 15, title: "Kopi", amount: 480, category: .food),
        .init(daysAgo: 2, hour: 13, minute: 5, title: "Chicken rice", amount: 1760, category: .food),
        .init(daysAgo: 2, hour: 21, minute: 10, title: "Mamak dinner", amount: 1620, category: .food),
        .init(daysAgo: 1, hour: 9, minute: 30, title: "Petrol", amount: 6000, category: .transport),
        .init(daysAgo: 1, hour: 12, minute: 40, title: "Lotus's", amount: 3480, category: .groceries),
        .init(daysAgo: 1, hour: 17, minute: 5, title: "Freelance · Hana Studio", amount: 40000, category: .moneyIn),
        .init(daysAgo: 0, hour: 8, minute: 42, title: "ZUS Coffee", amount: 1290, category: .food),
        .init(daysAgo: 0, hour: 13, minute: 15, title: "Nasi lemak + teh ais", amount: 950, category: .food),
        .init(daysAgo: 0, hour: 18, minute: 20, title: "Grab ride home", amount: 1870, category: .transport),
        .init(daysAgo: 0, hour: 19, minute: 42, title: "Burger", amount: 500, category: .food),
    ]

    /// Last month's food over the same days, so the Food page has something to compare with.
    static let lastMonthFoodTotal: Sen = 54_740

    public static func ledger(now: Date = Date(), calendar: Calendar = .current) -> [LedgerItem] {
        let today = calendar.startOfDay(for: now)
        var ledger: [LedgerItem] = []
        var foodThisMonth: [(date: Date, amount: Sen, title: String)] = []

        for item in items {
            guard let day = calendar.date(byAdding: .day, value: -item.daysAgo, to: today),
                  var date = calendar.date(bySettingHour: item.hour, minute: item.minute, second: 0, of: day) else { continue }
            if date > now { date = now }  // keep today's sample entries in the past
            ledger.append(LedgerItem(title: item.title, amount: item.amount, isIncome: item.category == .moneyIn,
                                     category: item.category, date: date))
            if item.category == .food { foodThisMonth.append((date, item.amount, item.title)) }
        }

        let thisMonthFood = foodThisMonth.reduce(0) { $0 + $1.amount }
        var lastMonth: [LedgerItem] = []
        var running = 0
        for (index, food) in foodThisMonth.enumerated() {
            guard let date = calendar.date(byAdding: .month, value: -1, to: food.date) else { continue }
            var amount = Int((Double(food.amount) * Double(lastMonthFoodTotal) / Double(max(thisMonthFood, 1)) / 10).rounded()) * 10
            if index == foodThisMonth.count - 1 { amount = lastMonthFoodTotal - running }
            running += amount
            lastMonth.append(LedgerItem(title: food.title, amount: max(amount, 10), isIncome: false, category: .food, date: date))
        }
        return ledger + lastMonth
    }
}
