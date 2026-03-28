# Testing Reference

Read ONLY the sections matching the developer's chosen testing framework and approach.

---

## Swift Testing Framework

Modern testing framework using `@Test` macro and `#expect` assertions. Available from Xcode 16+.

### Basics

```swift
import Testing
@testable import AppName

// Simple test
@Test func testProductIsAffordable() {
    let product = Product.preview
    #expect(product.isAffordable(budget: 100))
}

// Test with description
@Test("Product should be affordable when price is within budget")
func testAffordability() {
    let product = Product(name: "Test", price: Price(amount: 29.99))
    #expect(product.isAffordable(budget: 50))
}

// Test async code
@Test func testFetchProducts() async throws {
    let useCase = MockFetchUseCase()
    useCase.stubbedResult = [Product.preview]
    let result = try await useCase.fetchAll()
    #expect(result.count == 1)
}

// Test throws
@Test func testThrowsOnInvalidData() async {
    let repo = MockRepository()
    repo.shouldFail = true
    await #expect(throws: ProductError.self) {
        try await repo.fetchAll()
    }
}

// Parameterized tests
@Test(arguments: [0, -1, -100])
func testInvalidQuantity(quantity: Int) {
    let product = Product.preview
    #expect(!product.canPurchase(quantity: quantity))
}
```

### Grouped Tests with @Suite

```swift
@Suite("Product Aggregate Tests")
struct ProductAggregateTests {
    let product = Product.preview

    @Test func testIsAffordable() {
        #expect(product.isAffordable(budget: 100))
    }

    @Test func testHasGoodRating() {
        #expect(product.hasGoodRating())
    }

    @Test func testCanPurchase() {
        #expect(product.canPurchase(quantity: 1))
    }
}
```

### Assertion Reference

| Swift Testing | Purpose |
|--------------|---------|
| `#expect(condition)` | Assert true |
| `#expect(!condition)` | Assert false |
| `#expect(a == b)` | Assert equal |
| `#expect(a != b)` | Assert not equal |
| `#expect(throws: ErrorType.self) { }` | Assert throws |
| `#expect(value != nil)` | Assert not nil |
| `try #require(value)` | Unwrap or fail |

---

## XCTest Framework

Classic testing framework. Works with all Xcode versions.

### Basics

```swift
import XCTest
@testable import AppName

final class ProductTests: XCTestCase {

    var product: Product!

    override func setUp() {
        super.setUp()
        product = Product.preview
    }

    override func tearDown() {
        product = nil
        super.tearDown()
    }

    func testProductIsAffordable() {
        XCTAssertTrue(product.isAffordable(budget: 100))
    }

    func testProductNotAffordable() {
        XCTAssertFalse(product.isAffordable(budget: 5))
    }

    func testFetchProducts() async throws {
        let useCase = MockFetchUseCase()
        useCase.stubbedResult = [Product.preview]
        let result = try await useCase.fetchAll()
        XCTAssertEqual(result.count, 1)
    }

    func testThrowsOnInvalidData() async {
        let repo = MockRepository()
        repo.shouldFail = true
        do {
            _ = try await repo.fetchAll()
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is ProductError)
        }
    }
}
```

### Assertion Reference

| XCTest | Purpose |
|--------|---------|
| `XCTAssertTrue(condition)` | Assert true |
| `XCTAssertFalse(condition)` | Assert false |
| `XCTAssertEqual(a, b)` | Assert equal |
| `XCTAssertNotEqual(a, b)` | Assert not equal |
| `XCTAssertNil(value)` | Assert nil |
| `XCTAssertNotNil(value)` | Assert not nil |
| `XCTAssertThrowsError(try expr)` | Assert throws |
| `XCTFail("message")` | Force fail |

---

## TDD (Test-Driven Development)

Write tests FIRST, then implementation. Red → Green → Refactor.

### TDD Workflow

```
1. RED    → Write a failing test for the next behavior
2. GREEN  → Write minimum code to make the test pass
3. REFACTOR → Clean up without breaking tests
4. REPEAT → Next behavior
```

### TDD in Practice

```swift
// Step 1: RED — Write the test first
@Test("Cart total should sum all item prices")
func testCartTotal() {
    let cart = Cart()
    cart.addItem(Product(price: Price(amount: 10)), quantity: 2)  // 20
    cart.addItem(Product(price: Price(amount: 5)), quantity: 1)   // 5
    #expect(cart.totalPrice.amount == 25)
}
// This test won't compile yet — Cart doesn't have addItem or totalPrice

// Step 2: GREEN — Write minimum Cart implementation
struct Cart {
    private(set) var items: [CartItem] = []

    var totalPrice: Price {
        items.reduce(Price.zero) { $0 + ($1.product.price * $1.quantity) }
    }

    mutating func addItem(_ product: Product, quantity: Int) {
        items.append(CartItem(product: product, quantity: quantity))
    }
}
// Test passes!

// Step 3: REFACTOR — Improve without breaking tests
// e.g., add duplicate detection, validation
```

### TDD Test Order for a Module

Write tests in this order for each module:

1. **Domain entity tests** — Business rules, computed properties
2. **Value object tests** — Validation, formatting, operators
3. **UseCase tests** — Business logic orchestration (with mock repository)
4. **Repository tests** — Data mapping, API calls (with mock API client)
5. **Mapper tests** — DTO → Domain conversion, edge cases
6. **State/ViewModel tests** — State transitions, error handling
7. **Coordinator tests** — Navigation flow, view creation

---

## Test After

Implement first, then write tests. Practical when prototyping or working under time pressure.

### Test After Workflow

```
1. Implement the feature
2. Identify testable behaviors
3. Write tests covering: happy path, error cases, edge cases
4. Verify all tests pass
5. Refactor with test safety net
```

### What to Test (Priority Order)
1. ✅ Business rules and domain methods
2. ✅ State transitions (idle → loading → loaded → error)
3. ✅ Data mapping (DTO → Domain, edge cases)
4. ✅ Error handling paths
5. ✅ Boundary values (empty arrays, nil values, max/min)
6. ⬜ View layout (use #Preview instead)
7. ⬜ Third-party library behavior

---

## Mock Patterns

Mocks implement the same protocols as real classes but return controlled data.

### Mock Repository

```swift
final class Mock[Name]Repository: [Name]Repository {
    // Track calls
    var fetchAllCallCount = 0
    var fetchByIdCallCount = 0
    var lastSearchQuery: String?

    // Stub results
    var stubbedItems: [[Name]] = []
    var stubbedItem: [Name]?
    var shouldFail = false
    var stubbedError: [Name]Error = .fetchFailed(APIError.unknown(NSError(domain: "", code: -1)))

    func fetchAll() async throws -> [[Name]] {
        fetchAllCallCount += 1
        if shouldFail { throw stubbedError }
        return stubbedItems
    }

    func fetchById(_ id: UUID) async throws -> [Name] {
        fetchByIdCallCount += 1
        if shouldFail { throw stubbedError }
        guard let item = stubbedItem ?? stubbedItems.first(where: { $0.id == id }) else {
            throw [Name]Error.notFound
        }
        return item
    }

    func search(query: String) async throws -> [[Name]] {
        lastSearchQuery = query
        if shouldFail { throw stubbedError }
        return stubbedItems.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
```

### Mock API Client

```swift
final class MockAPIClient: APIClientProtocol {
    var stubbedData: Any?
    var shouldFail = false
    var stubbedError: APIError = .unknown(NSError(domain: "", code: -1))
    var requestCallCount = 0

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        requestCallCount += 1
        if shouldFail { throw stubbedError }
        guard let data = stubbedData as? T else {
            throw APIError.decodingError("Stubbed data type mismatch")
        }
        return data
    }

    // Convenience factory for previews
    static func withSampleData() -> MockAPIClient {
        let mock = MockAPIClient()
        // Configure with sample data
        return mock
    }
}
```

### Test Data Fixtures

```swift
extension Product {
    static var preview: Product {
        Product(
            id: UUID(uuidString: "12345678-1234-1234-1234-123456789ABC")!,
            name: "Test Product",
            price: Price(amount: 29.99),
            // ... all required properties
        )
    }

    static var sampleList: [Product] {
        [.preview, /* more samples */]
    }
}
```

### Guidelines
- Every protocol in the app gets a corresponding Mock class
- Mocks track method calls (call count, last parameters)
- Mocks support both success and failure paths (`shouldFail` flag)
- Provide test data fixtures as static properties on models
- Keep mocks in `Tests/Mocks/` folder

---

## Test File Structure

Organize test files to mirror the source structure:

```
Tests/
├── Domain/
│   ├── [Name]AggregateTests.swift
│   └── [ValueObject]Tests.swift
├── Data/
│   ├── [Name]RepositoryTests.swift
│   └── [Name]MapperTests.swift
├── Presentation/
│   ├── [Name]StateTests.swift          # or [Name]ViewModelTests.swift
│   └── [Name]CoordinatorTests.swift
├── Mocks/
│   ├── Mock[Name]Repository.swift
│   ├── MockAPIClient.swift
│   └── TestData.swift
└── Integration/
    └── [Name]IntegrationTests.swift
```

### Coverage Targets
- Domain layer: **90%+** (pure logic, easy to test)
- Data layer: **80%+** (mock external dependencies)
- Presentation layer: **70%+** (state logic, navigation)
- Overall module: **>80%**
