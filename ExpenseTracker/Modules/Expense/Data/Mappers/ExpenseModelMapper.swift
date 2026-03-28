import Foundation

enum ExpenseModelMapper {

    static func toDomain(_ model: ExpenseModel) -> Expense {
        Expense(
            id: model.id,
            amount: Money(amount: model.amount),
            category: ExpenseCategory(rawValue: model.categoryRaw) ?? .other,
            date: model.date,
            note: model.note
        )
    }

    static func toModel(_ expense: Expense) -> ExpenseModel {
        ExpenseModel(
            id: expense.id,
            amount: expense.amount.amount,
            categoryRaw: expense.category.rawValue,
            date: expense.date,
            note: expense.note
        )
    }
}
