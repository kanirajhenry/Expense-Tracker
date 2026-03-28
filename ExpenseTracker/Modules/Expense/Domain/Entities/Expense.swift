import Foundation

struct Expense: Equatable, Hashable, Identifiable, Sendable {
    let id: UUID
    let amount: Money
    let category: ExpenseCategory
    let date: Date
    let note: String
}

// MARK: - Fixtures

extension Expense {
    static let preview = Expense(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        amount: Money(amount: 24.99),
        category: .food,
        date: Date(timeIntervalSinceReferenceDate: 0),
        note: "Coffee and snack"
    )

    static let sampleList: [Expense] = [
        Expense(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            amount: Money(amount: 24.99),
            category: .food,
            date: Date(timeIntervalSinceReferenceDate: 0),
            note: "Coffee and snack"
        ),
        Expense(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            amount: Money(amount: 45.00),
            category: .transport,
            date: Date(timeIntervalSinceReferenceDate: 86400),
            note: "Train ticket"
        ),
        Expense(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            amount: Money(amount: 120.00),
            category: .housing,
            date: Date(timeIntervalSinceReferenceDate: 172800),
            note: "Utility bill"
        )
    ]
}
