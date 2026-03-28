import Testing
import Foundation
@testable import ExpenseTracker

@Suite("ExpenseListState")
@MainActor
struct ExpenseListStateTests {

    private func makeSUT() -> (state: ExpenseListState, useCase: MockExpenseManagementUseCase) {
        let useCase = MockExpenseManagementUseCase()
        let state = ExpenseListState(useCase: useCase)
        return (state, useCase)
    }

    @Test("load — populates expenses from use case")
    func loadPopulatesExpenses() async throws {
        let (sut, useCase) = makeSUT()
        useCase.stubbedExpenses = Expense.sampleList

        await sut.load()

        #expect(sut.expenses.count == Expense.sampleList.count)
        #expect(sut.isLoading == false)
        #expect(sut.error == nil)
    }

    @Test("load — sets error on failure")
    func loadSetsErrorOnFailure() async throws {
        let (sut, useCase) = makeSUT()
        useCase.shouldFail = true

        await sut.load()

        #expect(sut.error != nil)
        #expect(sut.expenses.isEmpty)
        #expect(sut.isLoading == false)
    }

    @Test("delete — calls use case and removes expense from list")
    func deleteCallsUseCaseAndUpdatesExpenses() async throws {
        let (sut, useCase) = makeSUT()
        useCase.stubbedExpenses = Expense.sampleList
        await sut.load()

        let toDelete = Expense.sampleList[0].id
        await sut.delete(id: toDelete)

        #expect(useCase.deleteCallCount == 1)
        #expect(sut.expenses.contains { $0.id == toDelete } == false)
    }

    @Test("load with selectedCategory — calls fetchExpenses(category:)")
    func loadWithCategoryFilter() async throws {
        let (sut, useCase) = makeSUT()
        useCase.stubbedExpenses = Expense.sampleList
        sut.selectedCategory = .food

        await sut.load()

        #expect(useCase.fetchByCategoryCallCount == 1)
        #expect(useCase.fetchAllCallCount == 0)
    }

    @Test("load with no selectedCategory — calls fetchAllExpenses()")
    func loadWithoutFilter() async throws {
        let (sut, useCase) = makeSUT()
        useCase.stubbedExpenses = Expense.sampleList
        sut.selectedCategory = nil

        await sut.load()

        #expect(useCase.fetchAllCallCount == 1)
        #expect(useCase.fetchByCategoryCallCount == 0)
    }
}
