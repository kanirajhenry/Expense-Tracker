import Testing
@testable import ExpenseTracker

@Suite("ExpenseCategory")
struct ExpenseCategoryTests {

    @Test("has exactly seven cases")
    func caseCount() {
        #expect(ExpenseCategory.allCases.count == 7)
    }

    @Test("all expected cases are present", arguments: [
        ExpenseCategory.food,
        .transport,
        .housing,
        .health,
        .entertainment,
        .shopping,
        .other
    ])
    func casesExist(category: ExpenseCategory) {
        #expect(ExpenseCategory.allCases.contains(category))
    }

    @Test("rawValues match display strings", arguments: zip(
        ExpenseCategory.allCases,
        ["Food", "Transport", "Housing", "Health", "Entertainment", "Shopping", "Other"]
    ))
    func rawValues(category: ExpenseCategory, expected: String) {
        #expect(category.rawValue == expected)
    }
}
