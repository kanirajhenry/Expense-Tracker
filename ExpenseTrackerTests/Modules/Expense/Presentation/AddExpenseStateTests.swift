import Testing
import Foundation
@testable import ExpenseTracker

@Suite("AddExpenseState")
@MainActor
struct AddExpenseStateTests {

    private func makeSUT() -> (state: AddExpenseState, useCase: MockExpenseManagementUseCase) {
        let useCase = MockExpenseManagementUseCase()
        let state = AddExpenseState(useCase: useCase)
        return (state, useCase)
    }

    @Test("save — sets validationError when amount is empty")
    func saveWithEmptyAmount() async throws {
        let (sut, _) = makeSUT()
        sut.amountText = ""
        await sut.save()
        #expect(sut.validationError != nil)
        #expect(sut.isSaving == false)
    }

    @Test("save — sets validationError when amount is zero")
    func saveWithZeroAmount() async throws {
        let (sut, _) = makeSUT()
        sut.amountText = "0"
        sut.selectedCategory = .food
        await sut.save()
        #expect(sut.validationError != nil)
    }

    @Test("save — sets validationError when category is nil")
    func saveWithNoCategory() async throws {
        let (sut, _) = makeSUT()
        sut.amountText = "10.00"
        sut.selectedCategory = nil
        await sut.save()
        #expect(sut.validationError != nil)
    }

    @Test("save — calls use case and resets form on success")
    func saveSuccess() async throws {
        let (sut, useCase) = makeSUT()
        sut.amountText = "15.50"
        sut.selectedCategory = .transport
        sut.note = "Bus fare"

        await sut.save()

        #expect(useCase.addCallCount == 1)
        #expect(useCase.lastAddedAmount == 15.50)
        #expect(sut.amountText == "")
        #expect(sut.selectedCategory == nil)
        #expect(sut.note == "")
        #expect(sut.validationError == nil)
    }

    @Test("save — sets validationError when use case throws")
    func saveFailure() async throws {
        let (sut, useCase) = makeSUT()
        useCase.shouldFail = true
        sut.amountText = "20.00"
        sut.selectedCategory = .food

        await sut.save()

        #expect(sut.validationError != nil)
        #expect(sut.isSaving == false)
    }

    @Test("isSaving is false after successful save")
    func isSavingFalseAfterSuccess() async throws {
        let (sut, _) = makeSUT()
        sut.amountText = "5.00"
        sut.selectedCategory = .health

        await sut.save()

        #expect(sut.isSaving == false)
    }
}
