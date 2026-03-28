import Foundation
import SwiftData

@Model
final class ExpenseModel {
    var id: UUID
    var amount: Double
    var categoryRaw: String
    var date: Date
    var note: String

    init(id: UUID, amount: Double, categoryRaw: String, date: Date, note: String) {
        self.id = id
        self.amount = amount
        self.categoryRaw = categoryRaw
        self.date = date
        self.note = note
    }
}
