import Foundation

struct Money: Equatable, Hashable, Codable, Sendable {
    let amount: Double

    // MARK: - Formatting

    func formatted(locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    // MARK: - Fixtures

    static let zero = Money(amount: 0.0)
    static let preview = Money(amount: 24.99)
}
