enum ExpenseCategory: String, CaseIterable, Codable, Sendable {
    case food          = "Food"
    case transport     = "Transport"
    case housing       = "Housing"
    case health        = "Health"
    case entertainment = "Entertainment"
    case shopping      = "Shopping"
    case other         = "Other"
}
