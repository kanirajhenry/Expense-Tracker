import Foundation
@testable import ExpenseTracker

final class MockExpenseRepository: ExpenseRepository {

    // MARK: - Configuration

    var shouldFail = false
    var stubbedExpenses: [Expense] = []

    // MARK: - Call tracking

    private(set) var saveCallCount = 0
    private(set) var deleteCallCount = 0
    private(set) var fetchAllCallCount = 0
    private(set) var fetchByCategoryCallCount = 0
    private(set) var lastSavedExpense: Expense?
    private(set) var lastDeletedId: UUID?
    private(set) var lastFetchedCategory: ExpenseCategory?

    // MARK: - ExpenseRepository

    func save(_ expense: Expense) async throws {
        guard !shouldFail else { throw ExpenseError.saveFailed }
        saveCallCount += 1
        lastSavedExpense = expense
        stubbedExpenses.append(expense)
    }

    func delete(id: UUID) async throws {
        guard !shouldFail else { throw ExpenseError.deleteFailed }
        deleteCallCount += 1
        lastDeletedId = id
        stubbedExpenses.removeAll { $0.id == id }
    }

    func fetchAll() async throws -> [Expense] {
        guard !shouldFail else { throw ExpenseError.fetchFailed }
        fetchAllCallCount += 1
        return stubbedExpenses
    }

    func fetch(category: ExpenseCategory) async throws -> [Expense] {
        guard !shouldFail else { throw ExpenseError.fetchFailed }
        fetchByCategoryCallCount += 1
        lastFetchedCategory = category
        return stubbedExpenses.filter { $0.category == category }
    }
}
