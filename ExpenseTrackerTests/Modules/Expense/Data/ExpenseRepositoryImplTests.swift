import Testing
import Foundation
import SwiftData
@testable import ExpenseTracker

@Suite("ExpenseRepositoryImpl — Integration")
struct ExpenseRepositoryImplTests {

    // MARK: - Helpers

    @MainActor
    private func makeRepository() throws -> ExpenseRepositoryImpl {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ExpenseModel.self, configurations: config)
        let storage = ExpenseLocalStorage(modelContainer: container)
        return ExpenseRepositoryImpl(localStorage: storage)
    }

    // MARK: - save + fetchAll

    @Test("save — persists expense and fetchAll returns it")
    @MainActor
    func saveAndFetchAll() async throws {
        let repo = try makeRepository()
        let expense = Expense.preview

        try await repo.save(expense)
        let results = try await repo.fetchAll()

        #expect(results.count == 1)
        #expect(results[0].id == expense.id)
        #expect(results[0].amount == expense.amount)
        #expect(results[0].category == expense.category)
        #expect(results[0].note == expense.note)
    }

    @Test("fetchAll — returns empty array when no expenses saved")
    @MainActor
    func fetchAllEmpty() async throws {
        let repo = try makeRepository()
        let results = try await repo.fetchAll()
        #expect(results.isEmpty)
    }

    // MARK: - delete

    @Test("delete — removes expense from storage")
    @MainActor
    func deleteExpense() async throws {
        let repo = try makeRepository()
        let expense = Expense.preview

        try await repo.save(expense)
        try await repo.delete(id: expense.id)
        let results = try await repo.fetchAll()

        #expect(results.isEmpty)
    }

    @Test("delete — does not throw when id does not exist")
    @MainActor
    func deleteNonexistent() async throws {
        let repo = try makeRepository()
        // Should not throw
        try await repo.delete(id: UUID())
    }

    // MARK: - fetch(category:)

    @Test("fetch(category:) — returns only matching category")
    @MainActor
    func fetchByCategory() async throws {
        let repo = try makeRepository()

        for expense in Expense.sampleList {
            try await repo.save(expense)
        }

        let foodExpenses = try await repo.fetch(category: .food)
        #expect(foodExpenses.allSatisfy { $0.category == .food })
        #expect(foodExpenses.count == Expense.sampleList.filter { $0.category == .food }.count)
    }
}
