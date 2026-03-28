# CLAUDE.md

## Project

This is **ExpenseTracker**, an iOS application built with SwiftUI.
Target: iOS 17+, Swift 5.9+.

## Spec-Driven Development

We follow Spec-Driven Development with OpenSpec.
- The specs at `openspec/specs/` are the source of truth.
- Always read `openspec/project.md` before generating architecture decisions.
- When implementing a feature, check `openspec/changes/` for active proposals.
- Use `/opsx:propose` to plan before coding new features.
- Use `/opsx:apply` to implement from spec artifacts.
- Never implement features without a spec proposal first.

## Architecture: Coordinator Pattern + Aggregate Model

- Navigation: Coordinator classes manage all navigation. Views NEVER create other views.
- State: State Holder classes named `[Name]State`, NOT ViewModel.
- Data flow: View → State Holder → UseCase → Repository → SwiftData/API
- Each module has: Domain / Data / Presentation / DI / Tests
- Coordinator creates views (Factory Pattern)
- Cross-module navigation through delegate protocols
- This is NOT MVVM. Do not use ViewModel naming or patterns.

## Layer Rules

- **Domain layer**: ZERO framework imports. Pure Swift only. Contains entities (structs), value objects, repository protocols, use cases, error types. NO @Model, NO SwiftUI, NO SwiftData.
- **Data layer**: Implements Domain protocols. Contains SwiftData @Model classes, mappers, local storage. @Model lives here ONLY.
- **Presentation layer**: SwiftUI views, State Holders, Coordinators. Depends on Domain only, never imports Data layer.

## Paradigm: Protocol-Oriented Programming (POP)

- Define behavior through protocols, not base classes
- Share implementation through protocol extensions
- Compose capabilities via multiple protocol conformance
- Every dependency is injected as a protocol, never a concrete type
- Use generics for reusable components (LocalStorage, LoadingState)

## Coding Standards

- `private` by default. `public` only at module boundaries.
- `let` over `var`. `guard` for early returns.
- `final` on all classes unless inheritance is intended.
- `async/await` for ALL asynchronous work. No completion handlers.
- `// MARK: -` comments in files > 50 lines.
- No force unwraps (`!`) except known-safe constants.
- Every SwiftUI view must have a `#Preview` block.
- File names match their primary type: `ExpenseListView.swift` → `struct ExpenseListView`.

## Naming

| Type | Convention | Example |
|------|-----------|---------|
| Entity | Clean noun (struct) | `Expense` |
| Value Object | Clean noun | `Money`, `ExpenseCategory` |
| Repository protocol | `[Name]Repository` | `ExpenseRepository` |
| Repository impl | `[Name]RepositoryImpl` | `ExpenseRepositoryImpl` |
| UseCase | `[Name]UseCase` | `ExpenseManagementUseCase` |
| State Holder | `[Name]State` | `ExpenseListState` |
| Coordinator | `[Name]Coordinator` | `ExpenseCoordinator` |
| View | `[Name]View` | `ExpenseListView` |
| SwiftData Model | `[Name]Model` | `ExpenseModel` |
| Mapper | `[Name]ModelMapper` | `ExpenseModelMapper` |
| Error enum | `[Name]Error` | `ExpenseError` |
| Mock | `Mock[Name]` | `MockExpenseRepository` |
| Test suite | `[Name]Tests` | `ExpenseAggregateTests` |
| Extension | `Type+Purpose.swift` | `Date+Formatting.swift` |

## Testing: Swift Testing + TDD

- Use `@Test` macro and `#expect` assertions
- Group tests with `@Suite("Description")`
- Parameterized tests with `@Test(arguments: [...])`
- TDD: Write tests FIRST, then implementation (Red → Green → Refactor)
- Do NOT use XCTest, XCTAssert, or XCTestCase
- Every protocol has a corresponding Mock in `Tests/Mocks/`
- Mocks track call counts and support `shouldFail` flag
- Test data fixtures as static `.preview` properties on entities
- Coverage target: >80% per module

## Module Structure

New modules follow this exact structure:
```
Modules/[Name]/
├── Domain/
│   ├── Entities/          # Pure Swift structs
│   ├── ValueObjects/
│   ├── Repositories/      # Protocols only
│   ├── UseCases/
│   └── Errors/
├── Data/
│   ├── Repositories/      # Implementations
│   ├── SwiftDataModels/   # @Model classes
│   ├── Mappers/           # Model ↔ Entity
│   └── LocalStorage/
├── Presentation/
│   ├── Coordinator/       # Navigation + view factory
│   ├── State/             # State Holders (NOT ViewModel)
│   └── Views/Components/
├── DI/
│   └── [Name]ModuleDIContainer.swift
└── Tests/
    ├── Domain/
    ├── Data/Mocks/
    ├── Presentation/
    └── Integration/
```

## FORBIDDEN

- ❌ No ViewModel naming — use `[Name]State`
- ❌ No SwiftUI or SwiftData imports in Domain layer
- ❌ No @Model in Domain layer — Data layer only
- ❌ No views creating other views directly — use Coordinator
- ❌ No completion handlers — use async/await
- ❌ No force unwraps in production code
- ❌ No XCTest — use Swift Testing only
- ❌ No skipping tests — TDD means tests FIRST
- ❌ No flat architecture — always Domain/Data/Presentation layers
- ❌ No implementing features without an OpenSpec proposal
