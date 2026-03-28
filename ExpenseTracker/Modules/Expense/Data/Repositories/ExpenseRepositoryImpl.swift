import Foundation

final class ExpenseRepositoryImpl: ExpenseRepository {

    // MARK: - Dependencies

    private let localStorage: any ExpenseLocalStorageProtocol

    init(localStorage: any ExpenseLocalStorageProtocol) {
        self.localStorage = localStorage
    }

    // MARK: - ExpenseRepository

    func save(_ expense: Expense) async throws {
        let model = ExpenseModelMapper.toModel(expense)
        try await localStorage.insert(model)
    }

    func delete(id: UUID) async throws {
        try await localStorage.delete(id: id)
    }

    func fetchAll() async throws -> [Expense] {
        let models = try await localStorage.fetchAll()
        return models.map(ExpenseModelMapper.toDomain)
    }

    func fetch(category: ExpenseCategory) async throws -> [Expense] {
        let models = try await localStorage.fetch(categoryRaw: category.rawValue)
        return models.map(ExpenseModelMapper.toDomain)
    }
}
