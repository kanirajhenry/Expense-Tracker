## Context

The ExpenseTracker iOS app was scaffolded on 2026-03-23 with only the Xcode default template. There are no models, views, or persistence layers. This design introduces the `Expense` module as the app's first feature, establishing the foundational architecture all future modules will follow: Coordinator Pattern + Aggregate Model across Domain / Data / Presentation layers.

Target platform: iOS 17+. Pure Swift 5.9+. No third-party dependencies.

## Goals / Non-Goals

**Goals:**
- Implement the `Expense` module following the canonical `Modules/[Name]/` structure
- Define a pure-Swift Domain layer: `Expense` aggregate root, `Money` and `ExpenseCategory` value objects, `ExpenseRepository` protocol, `ExpenseManagementUseCase`
- Implement the Data layer: `ExpenseModel` (@Model, Data layer only), `ExpenseModelMapper`, `ExpenseRepositoryImpl` backed by SwiftData
- Build the Presentation layer: `ExpenseCoordinator` (navigation + view factory), `ExpenseListState` / `AddExpenseState` / `ExpenseSummaryState` (State Holders, NOT ViewModels), and SwiftUI views
- Wire everything through `ExpenseModuleDIContainer`
- Follow TDD: write `@Test` / `#expect` tests before each implementation

**Non-Goals:**
- Cloud sync or iCloud backup
- Multi-currency support (single locale currency only)
- Budget limits or recurring expenses
- Editing existing expenses (create + delete only in v1)
- User authentication

## Decisions

### 1. Aggregate Model: `Expense` is the aggregate root
**Decision**: `Expense` is a pure Swift `struct` in the Domain layer — the aggregate root for this module. `Money` (amount + currency) and `ExpenseCategory` are value objects.
**Rationale**: Domain entities must be framework-free. A struct aggregate root makes the model immutable-by-default, easy to test, and safely passable across layers. SwiftData's `@Model` (a class) lives only in the Data layer as `ExpenseModel`; a mapper bridges the two.
**Alternative considered**: Reusing `@Model` class as the domain entity — rejected because it imports SwiftData into the Domain layer, violates the strict layer boundary, and couples business logic to persistence mechanics.

### 2. Repository Protocol in Domain, Implementation in Data
**Decision**: `ExpenseRepository` is a `protocol` in `Domain/Repositories/`. `ExpenseRepositoryImpl` in `Data/Repositories/` conforms to it, wrapping SwiftData operations via a `LocalStorage` abstraction.
**Rationale**: Presentation and Domain layers depend only on the protocol. This makes the use case and state holders fully testable with `MockExpenseRepository` without touching SwiftData at all. Follows Dependency Inversion (SOLID-D).
**Alternative considered**: Passing `ModelContext` directly into state holders — rejected because it imports SwiftData into Presentation, collapses the layers, and makes unit testing impossible without a live container.

### 3. `ExpenseManagementUseCase` orchestrates all business operations
**Decision**: A single use case — `ExpenseManagementUseCase` conforming to `ExpenseManagementUseCaseProtocol` — exposes `addExpense(...)`, `deleteExpense(id:)`, `fetchAllExpenses()`, and `fetchExpenses(category:)`. The use case owns the business rules (validation, formatting).
**Rationale**: Keeps state holders thin (UI state only) and domain logic centralized and testable. State holders call the use case; they do not perform validation or data access themselves.
**Alternative considered**: Putting validation and data access directly in state holders — rejected because it mixes UI state with business logic, duplicates rules across states, and prevents domain-level unit testing.

### 4. Coordinator Pattern: `ExpenseCoordinator` owns navigation and view creation
**Decision**: `ExpenseCoordinator` manages all navigation via a `NavigationPath` and acts as the view factory — it creates and injects every view. Views never instantiate other views.
**Rationale**: Decouples views from each other, centralizes navigation logic, and enables deep-link support later. State holders are created by the coordinator and injected into views, keeping views as pure render surfaces.
**Alternative considered**: Views creating child views directly — rejected because it tightly couples view hierarchy to navigation logic and violates the Factory Pattern requirement.

### 5. State Holders with `@Observable`, NOT ViewModels
**Decision**: Three state holders — `ExpenseListState`, `AddExpenseState`, `ExpenseSummaryState` — are `@Observable final class` objects named with the `State` suffix. They are owned by `ExpenseCoordinator` and injected into views.
**Rationale**: This is Coordinator Pattern, not MVVM. The `State` suffix signals the architectural pattern clearly and avoids confusion. `@Observable` integrates with SwiftUI's rendering without `@Published` boilerplate. State holders call the use case via `async/await`; no Combine for data fetching.
**Alternative considered**: `[Name]ViewModel` naming or `ObservableObject` — explicitly forbidden by project standards.

### 6. SwiftData `@Model` confined to Data layer
**Decision**: `ExpenseModel` (the `@Model` class) lives in `Data/SwiftDataModels/`. `ExpenseModelMapper` (a stateless enum) converts between `ExpenseModel` and the domain `Expense` struct. `ModelContainer` is configured in `ExpenseModuleDIContainer` and injected into the app environment once at startup.
**Rationale**: Domain layer stays import-free. If SwiftData is ever replaced, only the Data layer changes. The mapper is a clean, testable seam.
**Alternative considered**: SwiftData models as domain entities — rejected (strictly forbidden by project standards).

### 7. TDD with Swift Testing — tests written before implementation
**Decision**: Every layer is built Red → Green → Refactor using `@Test`, `#expect`, and `@Suite`. `MockExpenseRepository` (with call tracking and `shouldFail` flag) is written before `ExpenseRepositoryImpl`. All domain entities expose static `.preview` and `.sampleList` fixtures.
**Rationale**: TDD is a project mandate. Swift Testing (not XCTest) is the only permitted framework.
**Alternative considered**: Writing tests after implementation — explicitly forbidden by project standards.

## Risks / Trade-offs

- **iOS 17 minimum** → SwiftData has no fallback for iOS 16. Mitigation: set deployment target to 17.0 explicitly in project settings.
- **No expense editing in v1** → Users must delete and re-add to fix mistakes. Mitigation: swipe-to-delete is surfaced prominently; edit support is a natural follow-up change with no architectural rework needed.
- **Fixed `ExpenseCategory` enum** → Power users may want custom categories. Mitigation: `ExpenseCategory.other` + note field as escape hatch; custom categories deferred without breaking the current value object model.
- **Single `ExpenseManagementUseCase`** → May grow large. Mitigation: acceptable for v1 scope; can be split into `AddExpenseUseCase` / `FetchExpensesUseCase` etc. in a future refactor without changing the protocol surface.
- **`ModelContainer` injected at app root** → All views in the hierarchy gain SwiftData access. Mitigation: only the Data layer's repository impl ever touches the context; views and state holders never hold `ModelContext` directly.

## Module Structure

```
Modules/
└── Expense/
    ├── Domain/
    │   ├── Entities/           # Expense (aggregate root, pure Swift struct)
    │   ├── ValueObjects/       # Money, ExpenseCategory
    │   ├── Repositories/       # ExpenseRepository (protocol only)
    │   ├── UseCases/           # ExpenseManagementUseCaseProtocol + Impl
    │   └── Errors/             # ExpenseError
    ├── Data/
    │   ├── Repositories/       # ExpenseRepositoryImpl
    │   ├── SwiftDataModels/    # ExpenseModel (@Model)
    │   ├── Mappers/            # ExpenseModelMapper
    │   └── LocalStorage/       # SwiftData context wrapper
    ├── Presentation/
    │   ├── Coordinator/        # ExpenseCoordinator (navigation + view factory)
    │   ├── State/              # ExpenseListState, AddExpenseState, ExpenseSummaryState
    │   └── Views/
    │       └── Components/     # ExpenseRowView, CategoryFilterView, EmptyExpenseView
    ├── DI/
    │   └── ExpenseModuleDIContainer.swift
    └── Tests/
        ├── Domain/             # ExpenseAggregateTests, UseCaseTests
        ├── Data/
        │   └── Mocks/          # MockExpenseRepository
        ├── Presentation/       # State holder tests
        └── Integration/        # Full stack with real SwiftData in-memory container
```

## Data Flow

```
View → State Holder → UseCase Protocol → Repository Protocol → SwiftData
                ↑                              ↑
         (async/await)               (MockRepository in tests)
```

All dependencies flow inward — Domain has no dependencies; Data depends on Domain; Presentation depends on Domain only (never Data).
