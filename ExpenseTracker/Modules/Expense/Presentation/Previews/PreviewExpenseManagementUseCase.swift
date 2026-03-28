#if DEBUG
import Foundation

/// Lightweight preview stub for SwiftUI `#Preview` blocks.
/// Not a test mock — has no call tracking or failure injection.
/// Lives in the production target under `#if DEBUG` so previews compile.
final class PreviewExpenseManagementUseCase: ExpenseManagementUseCaseProtocol {

    var stubbedExpenses: [Expense]

    init(expenses: [Expense] = Expense.sampleList) {
        self.stubbedExpenses = expenses
    }

    func addExpense(amount: Double, category: ExpenseCategory, date: Date, note: String) async throws -> Expense {
        let expense = Expense(id: UUID(), amount: Money(amount: amount), category: category, date: date, note: note)
        stubbedExpenses.append(expense)
        return expense
    }

    func deleteExpense(id: UUID) async throws {
        stubbedExpenses.removeAll { $0.id == id }
    }

    func fetchAllExpenses() async throws -> [Expense] {
        stubbedExpenses
    }

    func fetchExpenses(category: ExpenseCategory) async throws -> [Expense] {
        stubbedExpenses.filter { $0.category == category }
    }
}
#endif
