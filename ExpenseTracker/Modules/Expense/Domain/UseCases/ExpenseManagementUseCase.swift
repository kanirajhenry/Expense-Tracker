import Foundation

// MARK: - ExpenseManagementUseCase

final class ExpenseManagementUseCase: ExpenseManagementUseCaseProtocol {

    // MARK: - Dependencies

    private let repository: any ExpenseRepository

    init(repository: any ExpenseRepository) {
        self.repository = repository
    }

    // MARK: - ExpenseManagementUseCaseProtocol

    func addExpense(amount: Double, category: ExpenseCategory, date: Date, note: String) async throws -> Expense {
        guard amount > 0 else { throw ExpenseError.invalidAmount }

        let expense = Expense(
            id: UUID(),
            amount: Money(amount: amount),
            category: category,
            date: date,
            note: note
        )

        do {
            try await repository.save(expense)
        } catch {
            throw ExpenseError.saveFailed
        }

        return expense
    }

    func deleteExpense(id: UUID) async throws {
        do {
            try await repository.delete(id: id)
        } catch {
            throw ExpenseError.deleteFailed
        }
    }

    func fetchAllExpenses() async throws -> [Expense] {
        do {
            return try await repository.fetchAll()
        } catch {
            throw ExpenseError.fetchFailed
        }
    }

    func fetchExpenses(category: ExpenseCategory) async throws -> [Expense] {
        do {
            return try await repository.fetch(category: category)
        } catch {
            throw ExpenseError.fetchFailed
        }
    }
}
