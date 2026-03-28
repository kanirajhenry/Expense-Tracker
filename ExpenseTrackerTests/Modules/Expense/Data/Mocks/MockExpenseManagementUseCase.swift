import Foundation
@testable import ExpenseTracker

final class MockExpenseManagementUseCase: ExpenseManagementUseCaseProtocol {

    // MARK: - Configuration

    var shouldFail = false
    var stubbedExpenses: [Expense] = []

    // MARK: - Call tracking

    private(set) var addCallCount = 0
    private(set) var deleteCallCount = 0
    private(set) var fetchAllCallCount = 0
    private(set) var fetchByCategoryCallCount = 0
    private(set) var lastAddedAmount: Double?
    private(set) var lastAddedCategory: ExpenseCategory?

    // MARK: - ExpenseManagementUseCaseProtocol

    func addExpense(amount: Double, category: ExpenseCategory, date: Date, note: String) async throws -> Expense {
        if shouldFail { throw ExpenseError.saveFailed }
        addCallCount += 1
        lastAddedAmount = amount
        lastAddedCategory = category
        let expense = Expense(id: UUID(), amount: Money(amount: amount), category: category, date: date, note: note)
        stubbedExpenses.append(expense)
        return expense
    }

    func deleteExpense(id: UUID) async throws {
        if shouldFail { throw ExpenseError.deleteFailed }
        deleteCallCount += 1
        stubbedExpenses.removeAll { $0.id == id }
    }

    func fetchAllExpenses() async throws -> [Expense] {
        if shouldFail { throw ExpenseError.fetchFailed }
        fetchAllCallCount += 1
        return stubbedExpenses
    }

    func fetchExpenses(category: ExpenseCategory) async throws -> [Expense] {
        if shouldFail { throw ExpenseError.fetchFailed }
        fetchByCategoryCallCount += 1
        return stubbedExpenses.filter { $0.category == category }
    }
}
