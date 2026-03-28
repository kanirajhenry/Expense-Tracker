import Foundation
import Observation

@Observable
@MainActor
final class ExpenseListState {

    // MARK: - Published state

    var expenses: [Expense] = []
    var selectedCategory: ExpenseCategory? = nil
    var isLoading: Bool = false
    var error: ExpenseError? = nil

    // MARK: - Dependencies

    private let useCase: any ExpenseManagementUseCaseProtocol

    init(useCase: any ExpenseManagementUseCaseProtocol) {
        self.useCase = useCase
    }

    // MARK: - Actions

    func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            if let category = selectedCategory {
                expenses = try await useCase.fetchExpenses(category: category)
            } else {
                expenses = try await useCase.fetchAllExpenses()
            }
        } catch let expenseError as ExpenseError {
            error = expenseError
            expenses = []
        } catch {
            self.error = .fetchFailed
            expenses = []
        }
    }

    func delete(id: UUID) async {
        do {
            try await useCase.deleteExpense(id: id)
            expenses.removeAll { $0.id == id }
        } catch let expenseError as ExpenseError {
            error = expenseError
        } catch {
            self.error = .deleteFailed
        }
    }
}
