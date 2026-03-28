import Foundation
import Testing
@testable import ExpenseTracker

@Suite("Money")
struct MoneyTests {

    @Test("equality — same amount is equal")
    func equality() {
        let a = Money(amount: 9.99)
        let b = Money(amount: 9.99)
        #expect(a == b)
    }

    @Test("inequality — different amounts are not equal")
    func inequality() {
        #expect(Money(amount: 1.00) != Money(amount: 2.00))
    }

    @Test("zero is a valid Money value")
    func zeroValue() {
        #expect(Money.zero.amount == 0.0)
    }

    @Test("formatted — produces non-empty string for positive amount")
    func formattedPositive() {
        let money = Money(amount: 42.50)
        let result = money.formatted(locale: Locale(identifier: "en_US"))
        #expect(result.isEmpty == false)
        #expect(result.contains("42"))
    }

    @Test("formatted — zero amount formats correctly")
    func formattedZero() {
        let result = Money.zero.formatted(locale: Locale(identifier: "en_US"))
        #expect(result.isEmpty == false)
        #expect(result.contains("0"))
    }

    @Test("preview fixture has positive amount")
    func previewFixture() {
        #expect(Money.preview.amount > 0)
    }
}
