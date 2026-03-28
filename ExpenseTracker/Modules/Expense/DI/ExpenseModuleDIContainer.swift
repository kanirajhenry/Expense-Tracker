import Foundation
import SwiftData

@MainActor
final class ExpenseModuleDIContainer {

    // MARK: - Persistence

    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: ExpenseModel.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Factory

    func makeCoordinator() -> ExpenseCoordinator {
        let localStorage = ExpenseLocalStorage(modelContainer: modelContainer)
        let repository = ExpenseRepositoryImpl(localStorage: localStorage)
        let useCase = ExpenseManagementUseCase(repository: repository)

        let listState    = ExpenseListState(useCase: useCase)
        let addState     = AddExpenseState(useCase: useCase)
        let summaryState = ExpenseSummaryState(useCase: useCase)

        return ExpenseCoordinator(
            listState: listState,
            addState: addState,
            summaryState: summaryState
        )
    }
}
