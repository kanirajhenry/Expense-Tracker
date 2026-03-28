import Testing
import Foundation
import SwiftData
@testable import ExpenseTracker

@Suite("Expense Module — Integration")
struct ExpenseModuleIntegrationTests {

    // MARK: - Helpers

    @MainActor
    private func makeUseCase() throws -> ExpenseManagementUseCase {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ExpenseModel.self, configurations: config)
        let storage = ExpenseLocalStorage(modelContainer: container)
        let repository = ExpenseRepositoryImpl(localStorage: storage)
        return ExpenseManagementUseCase(repository: repository)
    }

    // MARK: - Tests

    @Test("add expense via use case — fetchAll returns it")
    @MainActor
    func addAndFetch() async throws {
        let useCase = try makeUseCase()
        let expense = try await useCase.addExpense(
            amount: 50.0,
            category: .food,
            date: .now,
            note: "Integration test"
        )

        let all = try await useCase.fetchAllExpenses()

        #expect(all.count == 1)
        #expect(all[0].id == expense.id)
        #expect(all[0].amount.amount == 50.0)
        #expect(all[0].category == .food)
        #expect(all[0].note == "Integration test")
    }

    @Test("delete expense via use case — fetchAll returns empty")
    @MainActor
    func addAndDelete() async throws {
        let useCase = try makeUseCase()
        let expense = try await useCase.addExpense(
            amount: 30.0,
            category: .transport,
            date: .now,
            note: ""
        )

        try await useCase.deleteExpense(id: expense.id)
        let all = try await useCase.fetchAllExpenses()

        #expect(all.isEmpty)
    }

    @Test("multiple expenses — fetchExpenses(category:) returns only matching")
    @MainActor
    func fetchByCategory() async throws {
        let useCase = try makeUseCase()

        _ = try await useCase.addExpense(amount: 10, category: .food, date: .now, note: "")
        _ = try await useCase.addExpense(amount: 20, category: .food, date: .now, note: "")
        _ = try await useCase.addExpense(amount: 30, category: .transport, date: .now, note: "")

        let food = try await useCase.fetchExpenses(category: .food)
        let transport = try await useCase.fetchExpenses(category: .transport)

        #expect(food.count == 2)
        #expect(transport.count == 1)
        #expect(food.allSatisfy { $0.category == .food })
    }
}
