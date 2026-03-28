# Project: [APP_NAME]

> Copy this file to `openspec/project.md` after running `openspec init`.
> Replace all [PLACEHOLDERS] with your actual choices from the skill's Step 2 menu.

---

## Overview

[APP_NAME] is a [BRIEF_DESCRIPTION] iOS application built with SwiftUI.

- **Platform**: iOS [TARGET_VERSION]+
- **Language**: Swift [SWIFT_VERSION]+
- **UI Framework**: SwiftUI

---

## Architecture

- **Pattern**: [ARCHITECTURE_CHOICE]
  <!-- Options: Coordinator Pattern + Aggregate Model | MVVM | Clean Architecture | VIPER | MVC -->
- **Paradigm**: [PARADIGM_CHOICE]
  <!-- Options: Protocol-Oriented Programming (POP) | Object-Oriented Programming (OOP) | Hybrid -->
- **Generics**: [YES/NO]
- **Layer Separation**: Domain → Data → Presentation
  - **Domain**: Business logic, entities, repository protocols, use cases. ZERO framework imports — pure Swift only.
  - **Data**: Repository implementations, API client, DTOs, mappers, local storage.
  - **Presentation**: Coordinator/navigation, state management, SwiftUI views.

---

## Design Patterns

<!-- Remove patterns you didn't choose -->
- **Repository Pattern**: Data access abstracted behind protocols. Protocol in Domain, implementation in Data.
- **DI Container**: Per-module dependency assembly. One container per module wires all dependencies.
- **Factory Pattern**: Coordinator creates all views. Views never create other views.
- **Singleton**: Shared services only (auth, analytics). NOT for repositories or state.

---

## State Management

- **Approach**: [STATE_MANAGEMENT_CHOICE]
  <!-- Options: State Holder + Combine | ViewModel + @Observable | ViewModel + ObservableObject -->

<!-- If State Holder: -->
- State classes are named `[Name]State`, NOT `[Name]ViewModel`
- State holders use `@Observable` with `@Published` properties
- Combine is used ONLY for debouncing/reactive state, NOT for data fetching
- State holders are owned by Coordinators, injected into Views

<!-- If ViewModel: -->
- ViewModel classes are named `[Name]ViewModel`
- ViewModels use @Observable (iOS 17+) or ObservableObject (iOS 15-16)
- One ViewModel per screen

---

## Networking

- **Library**: [NETWORKING_CHOICE]
  <!-- Options: URLSession (custom wrapper) | Alamofire | Moya -->
- **Concurrency**: [CONCURRENCY_CHOICE]
  <!-- Options: async/await | Combine | GCD -->
- **API Client**: Generic, SOLID-compliant, with retry logic and exponential backoff
- **Endpoints**: Protocol-based (`APIEndpoint`), one enum per module
- **DTOs**: Separate from domain entities. Never expose DTOs to Domain or Presentation layer.
- **Mappers**: Stateless enum with `toDomain()` and `toDTO()` static methods

---

## Local Persistence

- **Approach**: [PERSISTENCE_CHOICE]
  <!-- Options: SwiftData | Core Data | UserDefaults + Codable | Realm | None -->

---

## Testing

- **Framework**: [TESTING_FRAMEWORK]
  <!-- Options: Swift Testing (@Test, #expect) | XCTest (XCTAssert, XCTestCase) -->
- **Approach**: [TESTING_APPROACH]
  <!-- Options: TDD (tests first) | Test After (implement first) -->
- **Coverage Target**: >80% per module
- **Mock Strategy**: Every protocol gets a Mock implementation with call tracking and stubbed results
- **Test Data**: Static `.preview` and `.sampleList` properties on all entities

---

## Module Structure

Every new module MUST follow this exact structure:

```
Modules/
└── [ModuleName]/
    ├── Domain/
    │   ├── Entities/           # Aggregate root (struct)
    │   ├── ValueObjects/       # Immutable value types
    │   ├── Repositories/       # Protocol ONLY
    │   ├── UseCases/           # Business orchestration
    │   └── Errors/             # Module-specific error enum
    ├── Data/
    │   ├── Repositories/       # Protocol implementation
    │   ├── APIClient/          # Module-specific endpoints
    │   ├── DTOs/               # API response models
    │   ├── Mappers/            # DTO ↔ Domain conversion
    │   └── LocalStorage/       # If local persistence needed
    ├── Presentation/
    │   ├── Coordinator/        # Navigation (or skip if MVVM/MVC)
    │   ├── State/ or ViewModels/
    │   └── Views/
    │       └── Components/
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

- **Entities**: `Product`, `Cart`, `User` (clean nouns)
- **Value Objects**: `Price`, `Rating`, `Money` (clean nouns)
- **Repositories**: `[Name]Repository` (protocol) / `[Name]RepositoryImpl` (implementation)
- **UseCases**: `[Name]UseCase` / `[Name]UseCaseProtocol`
- **Coordinators**: `[Name]Coordinator`
- **State Holders**: `[Name]State` (NOT `[Name]ViewModel` when using Coordinator pattern)
- **Views**: `[Name]View`, `[Name]RowView`, `[Name]DetailView`
- **DTOs**: `[Name]DTO`
- **Mappers**: `[Name]DTOMapper`
- **Errors**: `[Name]Error`
- **Tests**: `[Name]Tests`
- **Mocks**: `Mock[Name]`
- **Extensions**: `Type+Purpose.swift`
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
- No third-party libraries for core logic (unless explicitly chosen above).

---

## STRICTLY FORBIDDEN

- Do NOT use MVVM naming when architecture is Coordinator Pattern (no "ViewModel" suffix)
- Do NOT import SwiftUI or UIKit in Domain layer
- Do NOT create views directly from other views — use Coordinator/Factory
- Do NOT use completion handlers — use async/await
- Do NOT use force unwraps in production code
- Do NOT silently swallow errors
- Do NOT put DTOs in the Domain layer
- Do NOT skip tests for new code
