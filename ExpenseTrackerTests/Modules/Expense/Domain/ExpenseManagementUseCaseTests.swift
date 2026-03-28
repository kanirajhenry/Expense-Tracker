import Testing
import Foundation
@testable import ExpenseTracker

@Suite("ExpenseManagementUseCase")
struct ExpenseManagementUseCaseTests {

    // MARK: - Helpers

    private func makeSUT() -> (useCase: ExpenseManagementUseCase, repo: MockExpenseRepository) {
        let repo = MockExpenseRepository()
        let useCase = ExpenseManagementUseCase(repository: repo)
        return (useCase, repo)
    }

    // MARK: - addExpense

    @Test("addExpense — throws invalidAmount when amount is zero")
    func addExpenseZeroAmount() async throws {
        let (sut, _) = makeSUT()
        await #expect(throws: ExpenseError.invalidAmount) {
            try await sut.addExpense(amount: 0, category: .food, date: .now, note: "")
        }
    }

    @Test("addExpense — throws invalidAmount when amount is negative")
    func addExpenseNegativeAmount() async throws {
        let (sut, _) = makeSUT()
        await #expect(throws: ExpenseError.invalidAmount) {
            try await sut.addExpense(amount: -5, category: .food, date: .now, note: "")
        }
    }

    @Test("addExpense — saves expense to repository when valid")
    func addExpenseSuccess() async throws {
        let (sut, repo) = makeSUT()
        let expense = try await sut.addExpense(amount: 10.0, category: .food, date: .now, note: "lunch")
        #expect(repo.saveCallCount == 1)
        #expect(repo.lastSavedExpense?.id == expense.id)
        #expect(expense.amount.amount == 10.0)
        #expect(expense.category == .food)
        #expect(expense.note == "lunch")
    }

    @Test("addExpense — empty note is accepted")
    func addExpenseEmptyNote() async throws {
        let (sut, repo) = makeSUT()
        let expense = try await sut.addExpense(amount: 5.0, category: .other, date: .now, note: "")
        #expect(repo.saveCallCount == 1)
        #expect(expense.note == "")
    }

    // MARK: - deleteExpense

    @Test("deleteExpense — calls repository delete with correct id")
    func deleteExpense() async throws {
        let (sut, repo) = makeSUT()
        let id = UUID()
        try await sut.deleteExpense(id: id)
        #expect(repo.deleteCallCount == 1)
        #expect(repo.lastDeletedId == id)
    }

    @Test("deleteExpense — rethrows repository error as deleteFailed")
    func deleteExpenseFailure() async throws {
        let (sut, repo) = makeSUT()
        repo.shouldFail = true
        await #expect(throws: ExpenseError.deleteFailed) {
            try await sut.deleteExpense(id: UUID())
        }
    }

    // MARK: - fetchAllExpenses

    @Test("fetchAllExpenses — returns all repository results")
    func fetchAll() async throws {
        let (sut, repo) = makeSUT()
        repo.stubbedExpenses = Expense.sampleList
        let result = try await sut.fetchAllExpenses()
        #expect(result.count == Expense.sampleList.count)
        #expect(repo.fetchAllCallCount == 1)
    }

    // MARK: - fetchExpenses(category:)

    @Test("fetchExpenses(category:) — filters by category")
    func fetchByCategory() async throws {
        let (sut, repo) = makeSUT()
        repo.stubbedExpenses = Expense.sampleList
        let result = try await sut.fetchExpenses(category: .food)
        #expect(result.allSatisfy { $0.category == .food })
        #expect(repo.lastFetchedCategory == .food)
    }
}
