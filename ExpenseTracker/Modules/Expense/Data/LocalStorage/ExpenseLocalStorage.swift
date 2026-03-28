import Foundation
import SwiftData

// MARK: - Protocol

protocol ExpenseLocalStorageProtocol: Sendable {
    func insert(_ model: ExpenseModel) async throws
    func delete(id: UUID) async throws
    func fetchAll() async throws -> [ExpenseModel]
    func fetch(categoryRaw: String) async throws -> [ExpenseModel]
}

// MARK: - Implementation

final class ExpenseLocalStorage: ExpenseLocalStorageProtocol {

    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    // MARK: - ExpenseLocalStorageProtocol

    @MainActor
    func insert(_ model: ExpenseModel) async throws {
        let context = modelContainer.mainContext
        context.insert(model)
        try context.save()
    }

    @MainActor
    func delete(id: UUID) async throws {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<ExpenseModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try context.fetch(descriptor).first else { return }
        context.delete(model)
        try context.save()
    }

    @MainActor
    func fetchAll() async throws -> [ExpenseModel] {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<ExpenseModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    @MainActor
    func fetch(categoryRaw: String) async throws -> [ExpenseModel] {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<ExpenseModel>(
            predicate: #Predicate { $0.categoryRaw == categoryRaw },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
}
