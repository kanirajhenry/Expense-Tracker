import Foundation

protocol ExpenseRepository: Sendable {
    func save(_ expense: Expense) async throws
    func delete(id: UUID) async throws
    func fetchAll() async throws -> [Expense]
    func fetch(category: ExpenseCategory) async throws -> [Expense]
}
