import Foundation

enum ExpenseError: LocalizedError, Equatable {
    case invalidAmount
    case missingCategory
    case saveFailed
    case deleteFailed
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .invalidAmount:    return "Amount must be greater than zero."
        case .missingCategory:  return "Please select a category."
        case .saveFailed:       return "Failed to save the expense."
        case .deleteFailed:     return "Failed to delete the expense."
        case .fetchFailed:      return "Failed to load expenses."
        }
    }
}
