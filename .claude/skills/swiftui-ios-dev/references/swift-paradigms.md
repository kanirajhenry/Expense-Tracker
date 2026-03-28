# Swift Paradigms Reference

Read ONLY the sections matching the developer's chosen paradigm.

---

## Protocol-Oriented Programming (POP)

Protocols + extensions + composition over inheritance. The "Swift way."

### Core Principles
- Define behavior through protocols, not base classes
- Share implementation through protocol extensions (default implementations)
- Compose capabilities by conforming to multiple protocols
- Use associated types for type-safe abstractions
- Prefer value types (struct) with protocol conformance over class hierarchies

### Protocol Design

```swift
// Small, focused protocols (Interface Segregation)
protocol Fetchable {
    associatedtype Item
    func fetchAll() async throws -> [Item]
    func fetchById(_ id: UUID) async throws -> Item
}

protocol Searchable {
    associatedtype Item
    func search(query: String) async throws -> [Item]
}

protocol Persistable {
    associatedtype Item
    func save(_ item: Item) async throws -> Bool
    func delete(_ id: UUID) async throws -> Bool
}

// Compose protocols for specific needs
protocol ProductRepository: Fetchable, Searchable, Persistable where Item == Product {}
```

### Default Implementations via Extensions

```swift
// Shared behavior without inheritance
protocol Validatable {
    var isValid: Bool { get }
    func validate() throws
}

extension Validatable {
    func validate() throws {
        guard isValid else {
            throw ValidationError.invalid
        }
    }
}

// Any type that conforms gets validate() for free
struct Email: Validatable {
    let value: String
    var isValid: Bool {
        value.contains("@") && value.contains(".")
    }
}
```

### Protocol-Based Dependency Injection

```swift
// Define what you need, not what you use
protocol Networking {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

// Real implementation
final class APIClient: Networking { ... }

// Mock for testing
final class MockAPIClient: Networking { ... }

// Consumer depends on protocol, not concrete type
final class ProductFetchUseCase {
    private let network: Networking  // Protocol, not APIClient

    init(network: Networking) {
        self.network = network
    }
}
```

### Type Erasure (when needed)

```swift
// When you need to store protocol types with associated types
struct AnyRepository<Item>: Fetchable {
    private let _fetchAll: () async throws -> [Item]
    private let _fetchById: (UUID) async throws -> Item

    init<R: Fetchable>(_ repository: R) where R.Item == Item {
        _fetchAll = repository.fetchAll
        _fetchById = repository.fetchById
    }

    func fetchAll() async throws -> [Item] { try await _fetchAll() }
    func fetchById(_ id: UUID) async throws -> Item { try await _fetchById(id) }
}
```

---

## Object-Oriented Programming (OOP)

Classes + inheritance + polymorphism. Traditional approach.

### When to Use OOP in Swift
- Reference semantics needed (shared mutable state)
- Deep inheritance hierarchies make sense (rare in Swift)
- Interfacing with Objective-C frameworks
- Coordinators, services, and managers (naturally reference types)

### Base Class Pattern

```swift
class BaseRepository<T: Codable & Identifiable> {
    let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchAll(endpoint: APIEndpoint) async throws -> [T] {
        try await apiClient.request(endpoint)
    }

    // Subclasses override for specific behavior
    func transform(_ items: [T]) -> [T] {
        items  // Default: no transformation
    }
}

final class ProductRepository: BaseRepository<Product> {
    override func transform(_ items: [Product]) -> [Product] {
        items.filter { $0.inStock }
    }
}
```

### Abstract Factory with Classes

```swift
class ViewFactory {
    func makeListView() -> some View {
        fatalError("Subclass must override")
    }
}

final class ProductViewFactory: ViewFactory {
    override func makeListView() -> some View {
        ProductListView()
    }
}
```

---

## Hybrid (POP + OOP)

Use protocols for abstractions and composition. Use classes where reference semantics are needed.

### When to Use What

| Use Struct + Protocol | Use Class |
|----------------------|-----------|
| Data models (entities, value objects) | Coordinators (shared navigation state) |
| DTOs | State Holders / ViewModels (observed by views) |
| Mappers (stateless) | Services with mutable state (auth, cache) |
| Configuration types | DI Containers |

### Example: Hybrid Module

```swift
// Protocol (abstraction)
protocol CartManaging {
    var items: [CartItem] { get }
    func add(_ product: Product, quantity: Int) async throws
    func remove(_ productId: UUID) async throws
}

// Struct for data (value type)
struct CartItem: Identifiable, Hashable {
    let id: UUID
    let product: Product
    var quantity: Int
}

// Class for state management (reference type, observed)
@Observable
final class CartState: CartManaging {
    private(set) var items: [CartItem] = []
    private let repository: CartRepository

    init(repository: CartRepository) {
        self.repository = repository
    }

    func add(_ product: Product, quantity: Int) async throws { ... }
    func remove(_ productId: UUID) async throws { ... }
}
```

---

## Generics

Reusable, type-safe components that work with any type.

### Generic API Client

```swift
protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let (data, response) = try await session.data(for: buildRequest(endpoint))
        return try handleResponse(data: data, response: response)
    }

    private func handleResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        // Generic decoding
        try decoder.decode(T.self, from: data)
    }
}
```

### Generic Repository Base

```swift
protocol Repository {
    associatedtype Entity: Identifiable & Codable

    func fetchAll() async throws -> [Entity]
    func fetchById(_ id: Entity.ID) async throws -> Entity
    func save(_ entity: Entity) async throws
    func delete(_ id: Entity.ID) async throws
}

// Default implementation
extension Repository where Entity.ID == UUID {
    func fetchById(_ id: UUID) async throws -> Entity {
        let all = try await fetchAll()
        guard let entity = all.first(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }
        return entity
    }
}
```

### Generic Local Storage

```swift
final class LocalStorage<T: Codable & Identifiable> where T.ID == UUID {
    private let defaults: UserDefaults
    private let key: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(key: String, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    func save(_ items: [T]) throws {
        let data = try encoder.encode(items)
        defaults.set(data, forKey: key)
    }

    func load() throws -> [T] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return try decoder.decode([T].self, from: data)
    }

    func find(_ id: UUID) throws -> T? {
        try load().first { $0.id == id }
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
```

### Generic Loading State

```swift
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var data: T? {
        if case .loaded(let value) = self { return value }
        return nil
    }
}
```

### Generic View Modifier

```swift
struct LoadingOverlay<T>: ViewModifier {
    let state: LoadingState<T>

    func body(content: Content) -> some View {
        ZStack {
            content
            if state.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
            }
        }
    }
}

extension View {
    func loadingOverlay<T>(_ state: LoadingState<T>) -> some View {
        modifier(LoadingOverlay(state: state))
    }
}
```

### Where Clause Constraints

```swift
// Constrain generic types for specific capabilities
func sorted<T: Comparable>(items: [T]) -> [T] {
    items.sorted()
}

// Where clause for complex constraints
extension Array where Element: Identifiable, Element.ID == UUID {
    func find(byId id: UUID) -> Element? {
        first { $0.id == id }
    }
}

// Protocol with where clause
protocol Cacheable: Codable where Self: Identifiable {
    static var cacheKey: String { get }
    var expiresAt: Date? { get }
}
```

### Guidelines for Generics
- Use generics when the SAME logic applies to multiple types
- Don't over-generify — if only one type uses it, keep it concrete
- Prefer protocol constraints (`T: Decodable`) over unconstrained generics
- Use `where` clauses to narrow down capabilities
- Name type parameters meaningfully: `Entity`, `Item`, `Response` instead of just `T`
