# Project: ExpenseTracker

## Overview

ExpenseTracker is a personal expense tracking iOS application built with SwiftUI. Users can record daily expenses with categories, view expense lists, and see summary reports.

- **Platform**: iOS 17+
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI

---

## Architecture

- **Pattern**: Coordinator Pattern + Aggregate Model
- **Paradigm**: Protocol-Oriented Programming (POP)
- **Generics**: Yes — Generic APIClient, Generic LocalStorage
- **Layer Separation**: Domain → Data → Presentation
  - **Domain**: Business logic, entities, value objects, repository protocols, use cases. ZERO framework imports — pure Swift only.
  - **Data**: Repository implementations, DTOs, mappers, local storage (SwiftData).
  - **Presentation**: Coordinator (navigation), State Holder (state management), SwiftUI views.

---

## Design Patterns

- **Repository Pattern**: Data access abstracted behind protocols. Protocol in Domain, implementation in Data.
- **DI Container**: Per-module dependency assembly. One container per module wires all dependencies.
- **Factory Pattern**: Coordinator creates all views. Views never create other views.
- **SOLID Principles**: Applied throughout every layer.

---

## State Management

- **Approach**: State Holder + Combine
- State classes are named `[Name]State`, NOT `[Name]ViewModel`
- State holders use `@Observable` with `@Published` properties
- Combine is used ONLY for debouncing/reactive state, NOT for data fetching
- State holders are owned by Coordinators, injected into Views

---

## Networking

- **Library**: URLSession (custom wrapper, no third-party)
- **Concurrency**: async/await
- **API Client**: Generic, SOLID-compliant, with retry logic and exponential backoff
- **Endpoints**: Protocol-based (`APIEndpoint`), one enum per module
- **DTOs**: Separate from domain entities. Never expose DTOs to Domain or Presentation layer.
- **Mappers**: Stateless enum with `toDomain()` and `toDTO()` static methods

---

## Local Persistence

- **Approach**: SwiftData (iOS 17+)
- SwiftData `@Model` classes live in the Data layer, NOT in Domain
- Domain entities are plain Swift structs (no @Model)
- Mappers convert between SwiftData models and Domain entities
- Repository implementation wraps SwiftData operations

---

## Testing

- **Framework**: Swift Testing (@Test, #expect, @Suite)
- **Approach**: TDD (tests first, then implementation)
- **Coverage Target**: >80% per module
- **Mock Strategy**: Every protocol gets a Mock implementation with call tracking and stubbed results
- **Test Data**: Static `.preview` and `.sampleList` properties on all entities
- Do NOT use XCTest, XCTAssert, or XCTestCase

---

## Module Structure

Every new module MUST follow this exact structure:

```
Modules/
└── [ModuleName]/
    ├── Domain/
    │   ├── Entities/           # Aggregate root (struct, pure Swift)
    │   ├── ValueObjects/       # Immutable value types
    │   ├── Repositories/       # Protocol ONLY
    │   ├── UseCases/           # Business orchestration
    │   └── Errors/             # Module-specific error enum
    ├── Data/
    │   ├── Repositories/       # Protocol implementation
    │   ├── SwiftDataModels/    # @Model classes (Data layer only)
    │   ├── Mappers/            # SwiftData Model ↔ Domain Entity conversion
    │   └── LocalStorage/       # SwiftData queries and operations
    ├── Presentation/
    │   ├── Coordinator/        # Navigation manager + view factory
    │   ├── State/              # State Holder classes (NOT ViewModel)
    │   └── Views/
    │       └── Components/     # Reusable sub-views
    ├── DI/
    │   └── [Name]ModuleDIContainer.swift
    └── Tests/
        ├── Domain/
        ├── Data/
        │   └── Mocks/
        ├── Presentation/
        └── Integration/
```

---

## Naming Conventions

- **Entities**: `Expense`, `Category` (clean nouns, pure Swift structs)
- **Value Objects**: `Money`, `ExpenseCategory` (clean nouns)
- **Repositories**: `ExpenseRepository` (protocol) / `ExpenseRepositoryImpl` (implementation)
- **UseCases**: `ExpenseManagementUseCase` / `ExpenseManagementUseCaseProtocol`
- **Coordinators**: `ExpenseCoordinator`
- **State Holders**: `ExpenseListState`, `AddExpenseState` (suffix with `State`, NOT ViewModel)
- **Views**: `ExpenseListView`, `ExpenseRowView`, `AddExpenseView`
- **SwiftData Models**: `ExpenseModel` (suffix with `Model`, Data layer only)
- **Mappers**: `ExpenseModelMapper`
- **Errors**: `ExpenseError`
- **Tests**: `ExpenseAggregateTests`
- **Mocks**: `MockExpenseRepository`
- **Extensions**: `Date+Formatting.swift`
- **Files match their primary type**

---

## Coding Rules

- `private` by default. Widen access ONLY when needed.
- `let` over `var`. Immutability first.
- `guard` for early returns. `if let` for optional binding.
- `final` on all classes unless designed for inheritance.
- `// MARK: -` to organize files > 50 lines.
- No force unwrapping (`!`) except known-safe constants.
- Module-specific error enums with `LocalizedError` conformance.
- `#Preview` block on every SwiftUI view.
- Define behavior through protocols, not base classes (POP).
- Share implementation through protocol extensions.
- Every dependency is injected as a protocol, never a concrete type.
- No third-party libraries for core logic.

---

## STRICTLY FORBIDDEN

- ❌ Do NOT use ViewModel naming — use `[Name]State` (this is Coordinator pattern, not MVVM)
- ❌ Do NOT import SwiftUI or SwiftData in Domain layer — Domain is pure Swift
- ❌ Do NOT put @Model classes in Domain layer — they belong in Data layer
- ❌ Do NOT create views directly from other views — use Coordinator factory
- ❌ Do NOT use completion handlers — use async/await
- ❌ Do NOT use force unwraps in production code
- ❌ Do NOT silently swallow errors
- ❌ Do NOT skip tests — TDD means tests FIRST
- ❌ Do NOT use XCTest — use Swift Testing framework only
- ❌ Do NOT use flat architecture — every module needs Domain/Data/Presentation layers
