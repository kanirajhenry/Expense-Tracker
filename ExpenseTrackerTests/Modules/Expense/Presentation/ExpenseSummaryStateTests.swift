import Testing
import Foundation
@testable import ExpenseTracker

@Suite("ExpenseSummaryState")
@MainActor
struct ExpenseSummaryStateTests {

    private func makeSUT(expenses: [Expense] = []) -> (state: ExpenseSummaryState, useCase: MockExpenseManagementUseCase) {
        let useCase = MockExpenseManagementUseCase()
        useCase.stubbedExpenses = expenses
        let state = ExpenseSummaryState(useCase: useCase)
        return (state, useCase)
    }

    @Test("totalFormatted — returns non-empty string for non-zero total")
    func totalFormattedNonEmpty() async throws {
        let (sut, _) = makeSUT(expenses: Expense.sampleList)
        await sut.load()
        #expect(sut.totalFormatted.isEmpty == false)
    }

    @Test("totalFormatted — includes zero value when no expenses")
    func totalFormattedZero() async throws {
        let (sut, _) = makeSUT(expenses: [])
        await sut.load()
        #expect(sut.totalFormatted.contains("0"))
    }

    @Test("categoryBreakdown — omits categories with no expenses")
    func categoryBreakdownOmitsUnused() async throws {
        let (sut, _) = makeSUT(expenses: Expense.sampleList)
        await sut.load()
        let categories = sut.categoryBreakdown.map(\.0)
        // sampleList only has .food, .transport, .housing — others should be absent
        #expect(categories.contains(.health) == false)
        #expect(categories.contains(.entertainment) == false)
    }

    @Test("categoryBreakdown — includes only categories present in expenses")
    func categoryBreakdownContainsUsedCategories() async throws {
        let (sut, _) = makeSUT(expenses: Expense.sampleList)
        await sut.load()
        let categories = sut.categoryBreakdown.map(\.0)
        #expect(categories.contains(.food))
        #expect(categories.contains(.transport))
        #expect(categories.contains(.housing))
    }

    @Test("recentExpenses — capped at 5")
    func recentExpensesCappedAtFive() async throws {
        // Create 8 expenses
        let many: [Expense] = (1...8).map { i in
            Expense(
                id: UUID(),
                amount: Money(amount: Double(i) * 10),
                category: .other,
                date: Date(timeIntervalSinceReferenceDate: Double(i) * 1000),
                note: "expense \(i)"
            )
        }
        let (sut, _) = makeSUT(expenses: many)
        await sut.load()
        #expect(sut.recentExpenses.count == 5)
    }

    @Test("recentExpenses — shows all when fewer than 5")
    func recentExpensesShowsAllWhenFewer() async throws {
        let (sut, _) = makeSUT(expenses: Expense.sampleList)
        await sut.load()
        #expect(sut.recentExpenses.count == Expense.sampleList.count)
    }
}
