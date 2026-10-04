import Foundation

/// Words the parser knows. English, Malay and Manglish, all lowercase.
enum Lexicon {
    static let numberWords: [String: Int] = [
        "zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9,
        "ten": 10, "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14, "fifteen": 15, "sixteen": 16,
        "seventeen": 17, "eighteen": 18, "nineteen": 19, "twenty": 20, "thirty": 30, "forty": 40, "fifty": 50,
        "sixty": 60, "seventy": 70, "eighty": 80, "ninety": 90,
    ]

    /// After a number word under 20, these mean cents: "eight fifty" is 8.50.
    static let centsWords: Set<String> = ["fifty", "twenty", "thirty", "forty", "sixty", "seventy", "eighty", "ninety", "ten", "fifteen"]

    static let currencyWords: Set<String> = ["rm", "ringgit", "myr", "bucks", "dollars"]

    /// Words that start a new entry once the current one already has an amount.
    static let connectors: Set<String> = ["and", "then", "plus", "also", "dan", "lepastu", "after"]

    static let leadingFiller: Set<String> = [
        "i", "i've", "ive", "just", "spent", "spend", "spending", "paid", "pay", "bought", "buy", "got", "get", "had",
        "for", "on", "at", "the", "a", "an", "my", "some", "and", "then", "also", "plus", "today", "yesterday", "tadi",
        "semalam", "beli", "bayar", "untuk", "dekat", "kat", "with", "was", "it", "that", "dan", "after", "lepastu",
        "of", "to", "received", "receive",
    ]

    static let trailingFiller: Set<String> = [
        "for", "on", "at", "today", "yesterday", "tadi", "semalam", "just", "now", "and", "the", "a", "of", "to", "with", "only",
    ]

    static let income = PhraseMatcher([
        "paid me back", "pay me back", "paid me", "bayar balik", "received", "receive", "got paid", "salary", "gaji",
        "refund", "cashback", "cash back", "sent me", "transferred me", "transfer me", "duit masuk", "income",
        "freelance", "bonus", "allowance", "dividend", "sold", "reimburse", "reimbursed", "returned me", "gave me",
    ])

    /// Checked in order; the first category with a matching keyword wins. Multi-word keywords come first
    /// where it matters ("grab food" is food, plain "grab" is transport).
    static let categories: [(EntryCategory, PhraseMatcher)] = [
        (.food, PhraseMatcher([
            "grabfood", "grab food", "foodpanda", "food panda", "shopeefood", "bubble tea", "dim sum", "nasi", "mee",
            "mi goreng", "roti", "teh", "kopi", "coffee", "latte", "burger", "pizza", "kfc", "mcd", "mcdonald",
            "mcdonalds", "zus", "starbucks", "tealive", "chicken", "rice", "mamak", "snack", "kuih", "cendol", "laksa",
            "satay", "sushi", "ramen", "food", "drink", "drinks", "juice", "boba", "breakfast", "brunch", "lunch",
            "dinner", "supper", "makan", "tapau", "cafe", "restaurant", "bakery", "cake", "noodles", "char kuey teow",
            "bak kut teh", "steamboat",
        ])),
        (.groceries, PhraseMatcher([
            "jaya grocer", "village grocer", "99 speedmart", "speedmart", "groceries", "grocery", "grocer", "lotus",
            "lotus's", "aeon", "giant", "mydin", "tesco", "pasar", "market", "sayur", "vegetables", "fruits", "fruit",
            "milk", "eggs", "7-eleven", "7eleven", "seven eleven", "familymart", "family mart", "econsave",
        ])),
        (.transport, PhraseMatcher([
            "grab", "taxi", "bus", "mrt", "lrt", "train", "ktm", "toll", "parking", "petrol", "minyak", "fuel", "shell",
            "petronas", "caltex", "car wash", "e-hailing", "ehailing", "airasia", "flight", "indrive",
        ])),
        (.shopping, PhraseMatcher([
            "shopee", "lazada", "uniqlo", "zara", "h&m", "clothes", "shirt", "shoes", "ikea", "mr diy", "mr. diy",
            "watsons", "guardian", "amazon", "gift", "book", "books", "shopping",
        ])),
        (.bills, PhraseMatcher([
            "bill", "bills", "tnb", "electric", "electricity", "water", "air selangor", "syabas", "internet", "unifi",
            "maxis", "celcom", "digi", "umobile", "u mobile", "phone", "astro", "netflix", "spotify", "subscription",
            "insurance", "icloud", "youtube premium",
        ])),
        (.rent, PhraseMatcher(["rent", "sewa", "rental", "landlord"])),
    ]

    /// Moving money between your own accounts. Shows up on wallet screenshots; never counted as spending.
    static let transfer = PhraseMatcher([
        "reload", "top up", "top-up", "topup", "auto reload", "auto-reload", "transfer from bank", "from bank",
        "transfer to own", "own account",
    ])

    static func category(for lowercasedText: String) -> EntryCategory {
        for (category, matcher) in categories where matcher.matchesAny(lowercasedText) {
            return category
        }
        return .other
    }
}
