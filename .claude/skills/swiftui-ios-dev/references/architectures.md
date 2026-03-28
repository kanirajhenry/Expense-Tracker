# Architecture Patterns Reference

This file covers all supported architecture patterns. Read ONLY the section matching the developer's choice.

---

## Coordinator Pattern + Aggregate Model

Rich domain models (Aggregates) combined with Coordinator-based navigation. NOT MVVM — uses explicit State Holders instead of ViewModels.

### Folder Structure

```
Modules/
└── [ModuleName]/
    ├── Domain/
    │   ├── Entities/
    │   │   └── [Name].swift              # Aggregate Root (struct)
    │   ├── ValueObjects/
    │   │   └── [VO].swift                # Immutable value types
    │   ├── Repositories/
    │   │   └── [Name]Repository.swift    # Protocol ONLY
    │   ├── UseCases/
    │   │   └── [Name]UseCase.swift       # Business orchestration
    │   └── Errors/
    │       └── [Name]Error.swift
    ├── Data/
    │   ├── Repositories/
    │   │   └── [Name]RepositoryImpl.swift
    │   ├── APIClient/
    │   │   └── [Name]APIEndpoint.swift
    │   ├── DTOs/
    │   │   └── [Name]DTO.swift
    │   ├── Mappers/
    │   │   └── [Name]DTOMapper.swift
    │   └── LocalStorage/
    │       └── [Name]LocalStorage.swift
    ├── Presentation/
    │   ├── Coordinator/
    │   │   └── [Name]Coordinator.swift   # Navigation manager
    │   ├── State/
    │   │   └── [Name]State.swift         # State Holder (NOT ViewModel)
    │   └── Views/
    │       ├── [Name]ListView.swift
    │       ├── [Name]DetailView.swift
    │       └── Components/
    ├── DI/
    │   └── [Name]ModuleDIContainer.swift
    └── Tests/
```

### Navigation — Coordinator

```swift
@Observable
final class [Name]Coordinator {
    var navigationPath = NavigationPath()
    var presentedSheet: SheetType?

    private let diContainer: [Name]ModuleDIContainer

    enum SheetType: Identifiable {
        case detail([Name])
        var id: String { /* unique id */ }
    }

    init(diContainer: [Name]ModuleDIContainer) {
        self.diContainer = diContainer
    }

    // Factory — Coordinator creates ALL views
    func makeListView() -> some View {
        let state = diContainer.makeState()
        return [Name]ListView(state: state, coordinator: self)
    }

    func makeDetailView(for item: [Name]) -> some View {
        [Name]DetailView(item: item, coordinator: self)
    }

    func navigateToDetail(_ item: [Name]) {
        navigationPath.append(item)
    }

    func goBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = NavigationPath()
    }
}
```

### Data Flow

```
User Action → View → State Holder → UseCase → Repository → API/Storage
                ↑                                    |
                └────────── Data (Combine) ──────────┘
```

### Key Rules
- Coordinator creates views and injects dependencies (Factory Pattern)
- Views NEVER create other views — they ask the Coordinator
- State Holders are NOT ViewModels — they're explicit state containers named `[Name]State`
- Domain layer has ZERO framework imports (pure Swift)
- One Coordinator per module
- Cross-module navigation through delegate protocols

### Cross-Module Communication

```swift
protocol ProductModuleDelegate: AnyObject {
    func productModuleDidRequestAddToCart(_ product: Product)
}

// Root Coordinator conforms
extension RootCoordinator: ProductModuleDelegate {
    func productModuleDidRequestAddToCart(_ product: Product) {
        selectedTab = .cart
        cartCoordinator.addProduct(product)
    }
}
```

---

## MVVM (Model-View-ViewModel)

SwiftUI's most natural fit. ViewModel observes data and exposes state to Views.

### Folder Structure

```
Modules/
└── [ModuleName]/
    ├── Models/
    │   └── [Name].swift                  # Data models (Codable, Identifiable)
    ├── ViewModels/
    │   └── [Name]ViewModel.swift         # ObservableObject / @Observable
    ├── Views/
    │   ├── [Name]ListView.swift
    │   ├── [Name]DetailView.swift
    │   └── Components/
    ├── Services/
    │   ├── [Name]Service.swift           # API / business logic
    │   └── [Name]Repository.swift        # Data access (optional)
    └── Tests/
```

### Data Flow

```
User Action → View → ViewModel → Service → API/Storage
                ↑                    |
                └──── @Published ────┘
```

### ViewModel Template (iOS 17+ with @Observable)

```swift
import Foundation
import Observation

@Observable
final class [Name]ViewModel {
    var items: [[Name]] = []
    var isLoading = false
    var error: Error?

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

### ViewModel Template (iOS 15–16 with ObservableObject)

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

### Navigation — NavigationStack (no Coordinator)

```swift
struct [Name]ListView: View {
    @State private var viewModel = [Name]ViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.items) { item in
                NavigationLink(value: item) {
                    [Name]RowView(item: item)
                }
            }
            .navigationDestination(for: [Name].self) { item in
                [Name]DetailView(item: item)
            }
            .task { await viewModel.loadItems() }
        }
    }
}
```

### Key Rules
- One ViewModel per screen
- View never calls Service directly — always through ViewModel
- ViewModel never imports SwiftUI — only Foundation
- Models are plain structs

---

## Clean Architecture

Three strict layers with dependency rules: Presentation → Domain ← Data.

### Folder Structure

```
Modules/
└── [ModuleName]/
    ├── Domain/
    │   ├── Entities/
    │   │   └── [Name].swift              # Business entities
    │   ├── UseCases/
    │   │   └── [Name]UseCase.swift       # Single-purpose operations
    │   └── Repositories/
    │       └── [Name]Repository.swift    # Protocol ONLY
    ├── Data/
    │   ├── Repositories/
    │   │   └── [Name]RepositoryImpl.swift
    │   ├── DataSources/
    │   │   ├── Remote/
    │   │   │   └── [Name]RemoteDataSource.swift
    │   │   └── Local/
    │   │       └── [Name]LocalDataSource.swift
    │   ├── DTOs/
    │   │   └── [Name]DTO.swift
    │   └── Mappers/
    │       └── [Name]Mapper.swift
    ├── Presentation/
    │   ├── [Name]View.swift
    │   └── [Name]ViewModel.swift
    └── DI/
        └── [Name]DIContainer.swift
```

### Layer Rules
- **Domain**: Zero framework imports. Pure Swift. Contains entities, use case protocols, repository protocols.
- **Data**: Implements Domain protocols. Handles API, database, caching. Contains DTOs and mappers.
- **Presentation**: SwiftUI views and ViewModels. Depends on Domain (uses UseCases), never on Data.

### UseCase Template

```swift
protocol Fetch[Name]sUseCaseProtocol {
    func execute() async throws -> [[Name]]
}

final class Fetch[Name]sUseCase: Fetch[Name]sUseCaseProtocol {
    private let repository: [Name]Repository

    init(repository: [Name]Repository) {
        self.repository = repository
    }

    func execute() async throws -> [[Name]] {
        let items = try await repository.fetchAll()
        return items.filter { /* business rule */ }
    }
}
```

---

## VIPER

Strictest separation. Each module has 5 components: View, Interactor, Presenter, Entity, Router.

### Folder Structure

```
Modules/
└── [ModuleName]/
    ├── [Name]View.swift
    ├── [Name]Presenter.swift         # Formats data for View
    ├── [Name]Interactor.swift        # Business logic
    ├── [Name]Router.swift            # Navigation
    ├── [Name]Entity.swift            # Data models
    ├── [Name]ModuleBuilder.swift     # Factory assembles module
    └── [Name]Protocols.swift         # All contracts
```

### Component Flow

```
View ←→ Presenter ←→ Interactor
              ↓
           Router
```

### Module Builder

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

## MVC (Model-View-Controller)

Simplest pattern. In SwiftUI, the View absorbs the Controller role.

### Folder Structure

```
[AppName]/
├── Models/
│   ├── [Name].swift                  # Data + business logic
│   └── [Name]Store.swift             # @Observable model manager
├── Views/
│   ├── [Name]View.swift
│   └── Components/
├── Services/
│   └── [Name]Service.swift
└── Utilities/
```

### Model Manager (replaces Controller)

```swift
@Observable
final class [Name]Store {
    var items: [[Name]] = []
    var isLoading = false

    private let service: [Name]Service

    init(service: [Name]Service = .shared) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        items = (try? await service.fetchAll()) ?? []
    }
}
```

### When MVC Breaks Down
- View file > 200 lines with mixed logic
- Duplicating logic across views
- Can't unit test without SwiftUI views
- Migration path: extract Store → ViewModel = MVVM
