import Testing
import Foundation
@testable import ExpenseTracker

@Suite("ExpenseModelMapper")
struct ExpenseModelMapperTests {

    @Test("toDomain — maps all fields correctly")
    func toDomain() {
        let id = UUID()
        let date = Date(timeIntervalSinceReferenceDate: 1000)
        let model = ExpenseModel(id: id, amount: 19.99, categoryRaw: "Food", date: date, note: "Breakfast")

        let expense = ExpenseModelMapper.toDomain(model)

        #expect(expense.id == id)
        #expect(expense.amount.amount == 19.99)
        #expect(expense.category == .food)
        #expect(expense.date == date)
        #expect(expense.note == "Breakfast")
    }

    @Test("toModel — maps all fields correctly")
    func toModel() {
        let expense = Expense.preview
        let model = ExpenseModelMapper.toModel(expense)

        #expect(model.id == expense.id)
        #expect(model.amount == expense.amount.amount)
        #expect(model.categoryRaw == expense.category.rawValue)
        #expect(model.date == expense.date)
        #expect(model.note == expense.note)
    }

    @Test("round-trip — Expense → Model → Expense preserves all values")
    func roundTrip() {
        let original = Expense.preview
        let model = ExpenseModelMapper.toModel(original)
        let restored = ExpenseModelMapper.toDomain(model)

        #expect(restored.id == original.id)
        #expect(restored.amount == original.amount)
        #expect(restored.category == original.category)
        #expect(restored.date == original.date)
        #expect(restored.note == original.note)
    }

    @Test("toDomain — unknown categoryRaw maps to .other")
    func unknownCategoryMapsToOther() {
        let model = ExpenseModel(id: UUID(), amount: 5.0, categoryRaw: "UnknownXYZ", date: .now, note: "")
        let expense = ExpenseModelMapper.toDomain(model)
        #expect(expense.category == .other)
    }
}
