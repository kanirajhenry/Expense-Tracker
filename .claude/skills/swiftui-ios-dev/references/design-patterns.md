# Design Patterns Reference

Read ONLY the sections matching the developer's chosen patterns.

---

## Repository Pattern

Abstracts data access behind a protocol. Domain layer defines the interface, Data layer implements it.

### Repository Protocol (Domain Layer)

```swift
protocol [Name]Repository {
    func fetchAll() async throws -> [[Name]]
    func fetchById(_ id: UUID) async throws -> [Name]
    func search(query: String) async throws -> [[Name]]
    func save(_ entity: [Name]) async throws -> Bool
    func delete(_ id: UUID) async throws -> Bool
}
```

### Repository Implementation (Data Layer)

```swift
final class [Name]RepositoryImpl: [Name]Repository {
    private let apiClient: APIClientProtocol
    private let localStorage: [Name]LocalStorageProtocol?

    init(apiClient: APIClientProtocol, localStorage: [Name]LocalStorageProtocol? = nil) {
        self.apiClient = apiClient
        self.localStorage = localStorage
    }

    func fetchAll() async throws -> [[Name]] {
        do {
            let dtos: [[Name]DTO] = try await apiClient.request([Name]APIEndpoint.list)
            let entities = dtos.compactMap([Name]DTOMapper.toDomain)
            try? await localStorage?.saveAll(entities)
            return entities
        } catch {
            // Fallback to cache
            if let cached = try? await localStorage?.fetchAll() { return cached }
            throw [Name]Error.fetchFailed(error)
        }
    }

    func fetchById(_ id: UUID) async throws -> [Name] {
        let dto: [Name]DTO = try await apiClient.request([Name]APIEndpoint.getById(id: id))
        guard let entity = [Name]DTOMapper.toDomain(dto) else {
            throw [Name]Error.invalidData
        }
        return entity
    }

    func search(query: String) async throws -> [[Name]] {
        let dtos: [[Name]DTO] = try await apiClient.request([Name]APIEndpoint.search(query: query))
        return dtos.compactMap([Name]DTOMapper.toDomain)
    }

    func save(_ entity: [Name]) async throws -> Bool {
        let dto = [Name]DTOMapper.toDTO(entity)
        let _: [Name]DTO = try await apiClient.request([Name]APIEndpoint.create(dto))
        return true
    }

    func delete(_ id: UUID) async throws -> Bool {
        let _: EmptyResponse = try await apiClient.request([Name]APIEndpoint.delete(id: id))
        return true
    }
}
```

### Guidelines
- One repository per aggregate/entity
- Protocol in Domain layer, implementation in Data layer
- Always try remote first, fallback to local cache
- Convert API errors to module-specific errors
- Methods use Domain types (never DTOs) in their signatures

---

## DI Container

Centralized dependency assembly per module. The ONLY place where concrete implementations are created.

### Per-Module DI Container

```swift
final class [Name]ModuleDIContainer {
    // MARK: - External Dependencies
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    // MARK: - Data Layer
    func makeRepository() -> [Name]Repository {
        [Name]RepositoryImpl(apiClient: apiClient)
    }

    func makeLocalStorage() -> [Name]LocalStorageProtocol {
        [Name]LocalStorage()
    }

    // MARK: - Domain Layer
    func makeUseCase() -> [Name]UseCaseProtocol {
        [Name]UseCase(repository: makeRepository())
    }

    // MARK: - Presentation Layer (adapts to architecture)
    // For Coordinator Pattern:
    func makeState() -> [Name]State {
        [Name]State(useCase: makeUseCase())
    }

    func makeCoordinator() -> [Name]Coordinator {
        [Name]Coordinator(diContainer: self)
    }

    // For MVVM:
    func makeViewModel() -> [Name]ViewModel {
        [Name]ViewModel(service: makeUseCase())
    }

    // MARK: - Preview / Testing Support
    static func preview() -> [Name]ModuleDIContainer {
        [Name]ModuleDIContainer(apiClient: MockAPIClient.withSampleData())
    }
}
```

### App-Level DI Container

```swift
final class AppDIContainer {
    // Shared services
    lazy var apiClient: APIClientProtocol = APIClient(configuration: .default)

    // Module containers
    func makeProductContainer() -> ProductModuleDIContainer {
        ProductModuleDIContainer(apiClient: apiClient)
    }

    func makeCartContainer() -> CartModuleDIContainer {
        CartModuleDIContainer(apiClient: apiClient)
    }
}
```

### Guidelines
- One DI Container per module
- App-level container creates module containers
- Accept protocols in init (not concrete types) for testability
- Provide `.preview()` factory for SwiftUI previews
- Tests inject mocks through the same init

---

## Factory Pattern

Encapsulates complex object creation. Used by Coordinators and DI Containers to create views and dependencies.

### View Factory (inside Coordinator)

```swift
// Coordinator IS the factory for its module's views
final class [Name]Coordinator {
    private let diContainer: [Name]ModuleDIContainer

    func makeListView() -> some View {
        let state = diContainer.makeState()
        return [Name]ListView(state: state, coordinator: self)
    }

    func makeDetailView(for item: [Name]) -> some View {
        [Name]DetailView(item: item, coordinator: self)
    }
}
```

### Module Builder Factory (for VIPER)

```swift
enum [Name]ModuleBuilder {
    static func build() -> some View {
        let interactor = [Name]Interactor()
        let router = [Name]Router()
        let presenter = [Name]Presenter(interactor: interactor, router: router)
        return [Name]View(presenter: presenter, router: router)
    }
}
```

---

## Service Locator

Runtime dependency resolution. An alternative to DI Container where dependencies are registered and resolved at runtime.

```swift
final class ServiceLocator {
    static let shared = ServiceLocator()
    private var services: [String: Any] = [:]

    func register<T>(_ service: T, for type: T.Type) {
        let key = String(describing: type)
        services[key] = service
    }

    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let service = services[key] as? T else {
            fatalError("No service registered for \(key)")
        }
        return service
    }
}

// Registration
ServiceLocator.shared.register(ProductRepositoryImpl() as ProductRepository, for: ProductRepository.self)

// Resolution
let repo = ServiceLocator.shared.resolve(ProductRepository.self)
```

### When to Use
- Prefer DI Container for most apps (compile-time safety)
- Use Service Locator when you need runtime flexibility or plugin architecture

---

## Singleton

Shared instances for services that should exist once in the app. Use sparingly.

```swift
final class AuthService {
    static let shared = AuthService()
    private init() {}  // Prevent external instantiation

    private(set) var isAuthenticated = false
    private(set) var currentUser: User?

    func signIn(email: String, password: String) async throws -> User { ... }
    func signOut() { ... }
}
```

### When to Use
- Network clients, auth services, analytics — truly app-wide services
- NOT for repositories or view models — those should be injected

---

## State Holder (with Combine)

Explicit state container — NOT a ViewModel. Named `[Name]State`, uses `@Published` for reactive UI updates and Combine for debouncing/search.

This approach is used with the **Coordinator Pattern** architecture.

```swift
import Foundation
import Combine
import Observation

@Observable
final class [Name]State {
    // MARK: - Published State
    @Published var items: [[Name]] = []
    @Published var isLoading: Bool = false
    @Published var error: [Name]Error?
    @Published var searchQuery: String = ""

    // MARK: - Computed
    var filteredItems: [[Name]] {
        if searchQuery.isEmpty { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    var hasError: Bool { error != nil }
    var isEmpty: Bool { items.isEmpty && !isLoading }

    // MARK: - Dependencies
    private let useCase: [Name]UseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(useCase: [Name]UseCaseProtocol) {
        self.useCase = useCase
        setupSearchDebounce()
    }

    // MARK: - Actions
    func fetchItems() async {
        isLoading = true
        error = nil
        do {
            items = try await useCase.fetchAll()
        } catch {
            self.error = error as? [Name]Error ?? .fetchFailed(error)
        }
        isLoading = false
    }

    func clearError() { error = nil }

    // MARK: - Private
    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                Task {
                    if query.isEmpty {
                        await self.fetchItems()
                    } else {
                        await self.searchItems(query: query)
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func searchItems(query: String) async {
        isLoading = true
        error = nil
        do {
            items = try await useCase.search(query: query)
        } catch {
            self.error = error as? [Name]Error ?? .fetchFailed(error)
        }
        isLoading = false
    }
}
```

### Key Differences from ViewModel
- Named `State`, not `ViewModel`
- Owned by Coordinator, not by View
- Coordinator injects it into the View
- Combine used only for debouncing/reactive state — NOT for data fetching

---

## ViewModel with @Observable (iOS 17+)

Modern approach using the `@Observable` macro. Used with MVVM or Clean Architecture.

```swift
import Foundation
import Observation

@Observable
final class [Name]ViewModel {
    var items: [[Name]] = []
    var isLoading = false
    var error: Error?
    var searchText = ""

    var filteredItems: [[Name]] {
        if searchText.isEmpty { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private let service: [Name]ServiceProtocol

    init(service: [Name]ServiceProtocol) {
        self.service = service
    }

    func loadItems() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await service.fetchAll()
        } catch {
            self.error = error
        }
    }
}
```

### View Usage
```swift
struct [Name]ListView: View {
    @State private var viewModel = [Name]ViewModel(service: [Name]Service())

    var body: some View {
        // ...
        .task { await viewModel.loadItems() }
    }
}
```

---

## ViewModel with ObservableObject (iOS 15–16)

Classic approach for backward compatibility.

```swift
import Foundation
import Combine

final class [Name]ViewModel: ObservableObject {
    @Published var items: [[Name]] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let service: [Name]ServiceProtocol

    init(service: [Name]ServiceProtocol) {
        self.service = service
    }

    @MainActor
    func loadItems() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await service.fetchAll()
        } catch {
            self.error = error
        }
    }
}
```

### View Usage
```swift
struct [Name]ListView: View {
    @StateObject private var viewModel = [Name]ViewModel(service: [Name]Service())
    // or @ObservedObject if injected from parent

    var body: some View {
        // ...
        .task { await viewModel.loadItems() }
    }
}
```
