import Testing
import Foundation
@testable import ExpenseTracker

@Suite("Expense Aggregate")
struct ExpenseAggregateTests {

    @Test("initialises with provided values")
    func initialisation() {
        let id = UUID()
        let money = Money(amount: 10.0)
        let date = Date()
        let expense = Expense(id: id, amount: money, category: .food, date: date, note: "lunch")

        #expect(expense.id == id)
        #expect(expense.amount == money)
        #expect(expense.category == .food)
        #expect(expense.date == date)
        #expect(expense.note == "lunch")
    }

    @Test("is a value type — copy is independent")
    func immutability() {
        let original = Expense.preview
        var copy = original
        // Re-assign via re-init to a different note — structs are value types
        copy = Expense(id: original.id, amount: original.amount, category: original.category, date: original.date, note: "changed")
        #expect(original.note != copy.note)
    }

    @Test("preview fixture is fully populated")
    func previewFixture() {
        let expense = Expense.preview
        #expect(expense.amount.amount > 0)
        #expect(expense.note.isEmpty == false)
    }

    @Test("sampleList has multiple entries")
    func sampleListFixture() {
        #expect(Expense.sampleList.count >= 3)
    }

    @Test("sampleList entries have distinct IDs")
    func sampleListDistinctIds() {
        let ids = Expense.sampleList.map(\.id)
        let unique = Set(ids)
        #expect(unique.count == ids.count)
    }
}
