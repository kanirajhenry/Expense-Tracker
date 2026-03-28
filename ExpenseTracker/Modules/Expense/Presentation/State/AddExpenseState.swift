import Foundation
import Observation

@Observable
@MainActor
final class AddExpenseState {

    // MARK: - Form fields

    var amountText: String = ""
    var selectedCategory: ExpenseCategory? = nil
    var date: Date = .now
    var note: String = ""

    // MARK: - UI state

    var validationError: String? = nil
    var isSaving: Bool = false

    // MARK: - Dependencies

    private let useCase: any ExpenseManagementUseCaseProtocol

    init(useCase: any ExpenseManagementUseCaseProtocol) {
        self.useCase = useCase
    }

    // MARK: - Actions

    func save() async {
        validationError = nil

        guard let amount = Double(amountText), amount > 0 else {
            validationError = ExpenseError.invalidAmount.errorDescription
            return
        }

        guard let category = selectedCategory else {
            validationError = ExpenseError.missingCategory.errorDescription
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await useCase.addExpense(
                amount: amount,
                category: category,
                date: date,
                note: note
            )
            resetForm()
        } catch let error as ExpenseError {
            validationError = error.errorDescription
        } catch {
            validationError = ExpenseError.saveFailed.errorDescription
        }
    }

    // MARK: - Private

    private func resetForm() {
        amountText = ""
        selectedCategory = nil
        date = .now
        note = ""
        validationError = nil
    }
}
