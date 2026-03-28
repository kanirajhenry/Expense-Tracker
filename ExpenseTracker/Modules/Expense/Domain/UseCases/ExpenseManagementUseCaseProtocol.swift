import Foundation

protocol ExpenseManagementUseCaseProtocol: Sendable {
    func addExpense(amount: Double, category: ExpenseCategory, date: Date, note: String) async throws -> Expense
    func deleteExpense(id: UUID) async throws
    func fetchAllExpenses() async throws -> [Expense]
    func fetchExpenses(category: ExpenseCategory) async throws -> [Expense]
}
