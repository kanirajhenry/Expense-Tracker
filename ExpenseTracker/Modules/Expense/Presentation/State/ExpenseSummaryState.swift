import Foundation
import Observation

@Observable
@MainActor
final class ExpenseSummaryState {

    // MARK: - Published state

    var expenses: [Expense] = []
    var error: ExpenseError? = nil

    // MARK: - Computed

    var totalFormatted: String {
        let total = expenses.reduce(0.0) { $0 + $1.amount.amount }
        return Money(amount: total).formatted()
    }

    var categoryBreakdown: [(ExpenseCategory, String)] {
        let grouped = Dictionary(grouping: expenses, by: \.category)
        return grouped
            .compactMap { category, items -> (ExpenseCategory, Double)? in
                let total = items.reduce(0.0) { $0 + $1.amount.amount }
                guard total > 0 else { return nil }
                return (category, total)
            }
            .sorted { $0.1 > $1.1 }
            .map { (category, total) in
                (category, Money(amount: total).formatted())
            }
    }

    var recentExpenses: [Expense] {
        let sorted = expenses.sorted { $0.date > $1.date }
        return Array(sorted.prefix(5))
    }

    // MARK: - Dependencies

    private let useCase: any ExpenseManagementUseCaseProtocol

    init(useCase: any ExpenseManagementUseCaseProtocol) {
        self.useCase = useCase
    }

    // MARK: - Actions

    func load() async {
        do {
            expenses = try await useCase.fetchAllExpenses()
        } catch let expenseError as ExpenseError {
            error = expenseError
        } catch {
            self.error = .fetchFailed
        }
    }
}
