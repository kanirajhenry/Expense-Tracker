# CLAUDE.md — Persistent Instructions for Claude Code

> Copy this file to the ROOT of your iOS project.
> Claude Code reads this file on EVERY session automatically.
> Replace [PLACEHOLDERS] with your actual choices.

---

## Project

This is **[APP_NAME]**, an iOS application built with SwiftUI.
Target: iOS [VERSION]+, Swift [VERSION]+.

## Spec-Driven Development

We follow Spec-Driven Development with OpenSpec.
- The specs at `openspec/specs/` are the source of truth.
- Always read `openspec/project.md` before generating architecture decisions.
- When implementing a feature, check `openspec/changes/` for active proposals.
- Use `/opsx:propose` to plan before coding new features.
- Use `/opsx:apply` to implement from spec artifacts.
- Never implement features without a spec proposal first.

## Architecture: [ARCHITECTURE_NAME]

<!-- === COORDINATOR PATTERN (uncomment if chosen) ===
- Architecture: Coordinator Pattern + Aggregate Model
- Navigation: Coordinator classes manage all navigation. Views NEVER create other views.
- State: State Holder classes named `[Name]State`, NOT ViewModel.
- Data flow: View → State → UseCase → Repository → API/Storage
- Each module has: Domain / Data / Presentation / DI / Tests
- Coordinator creates views (Factory Pattern)
- Cross-module navigation through delegate protocols
-->

<!-- === MVVM (uncomment if chosen) ===
- Architecture: MVVM
- Navigation: NavigationStack in views, no Coordinator
- State: ViewModel classes named `[Name]ViewModel`
- Data flow: View → ViewModel → Service → API/Storage
- One ViewModel per screen
-->

<!-- === CLEAN ARCHITECTURE (uncomment if chosen) ===
- Architecture: Clean Architecture
- Layers: Presentation → Domain ← Data (strict dependency rules)
- Domain: UseCases + Entity protocols + Repository protocols
- Data: Repository Implementations + DataSources + DTOs
- Presentation: Views + ViewModels
-->

## Layer Rules

- **Domain layer**: ZERO framework imports. Pure Swift only. Contains entities, value objects, repository protocols, use cases, error types.
- **Data layer**: Implements Domain protocols. Contains API client, DTOs, mappers, local storage. Never imported by Presentation.
- **Presentation layer**: SwiftUI views, state/viewmodel, navigation. Depends on Domain only.

## Paradigm: [POP/OOP/Hybrid]

<!-- === POP (uncomment if chosen) ===
- Define behavior through protocols, not base classes
- Share implementation through protocol extensions
- Compose capabilities via multiple protocol conformance
- Every dependency is injected as a protocol, never a concrete type
-->

<!-- === OOP (uncomment if chosen) ===
- Use class hierarchies where inheritance is natural
- Reference semantics for coordinators, services, state holders
-->

## Coding Standards

- `private` by default. `public` only at module boundaries.
- `let` over `var`. `guard` for early returns.
- `final` on all classes unless inheritance is intended.
- `async/await` for ALL asynchronous work. No completion handlers.
- `// MARK: -` comments in files > 50 lines.
- No force unwraps (`!`) except known-safe constants like `URL(string: "constant")!`.
- Every SwiftUI view must have a `#Preview` block.
- File names match their primary type: `ProductListView.swift` → `struct ProductListView`.

## Naming

| Type | Convention | Example |
|------|-----------|---------|
| Entity | Clean noun | `Product`, `Cart` |
| Value Object | Clean noun | `Price`, `Money` |
| Repository protocol | `[Name]Repository` | `ProductRepository` |
| Repository impl | `[Name]RepositoryImpl` | `ProductRepositoryImpl` |
| UseCase | `[Name]UseCase` | `ProductFetchUseCase` |
| State Holder | `[Name]State` | `ProductListState` |
| ViewModel | `[Name]ViewModel` | `ProductViewModel` |
| View | `[Name]View` | `ProductListView` |
| DTO | `[Name]DTO` | `ProductDTO` |
| Mapper | `[Name]DTOMapper` | `ProductDTOMapper` |
| Error enum | `[Name]Error` | `ProductError` |
| Mock | `Mock[Name]` | `MockProductRepository` |
| Test suite | `[Name]Tests` | `ProductAggregateTests` |
| Extension | `Type+Purpose.swift` | `Date+Formatting.swift` |

## Testing: [Swift Testing / XCTest]

<!-- === SWIFT TESTING (uncomment if chosen) ===
- Use `@Test` macro and `#expect` assertions
- Group tests with `@Suite("Description")`
- Parameterized tests with `@Test(arguments: [...])`
- NO XCTest classes or XCTAssert calls
-->

<!-- === XCTEST (uncomment if chosen) ===
- Use `XCTestCase` subclasses
- Use `setUp()` / `tearDown()` for test lifecycle
- Use `XCTAssertEqual`, `XCTAssertTrue`, etc.
-->

- Every protocol has a corresponding Mock in `Tests/Mocks/`
- Mocks track call counts and support `shouldFail` flag
- Test data fixtures as static `.preview` properties on entities
- Coverage target: >80% per module

## Error Handling

- Module-specific error enums conforming to `LocalizedError`
- Wrap API errors: `case fetchFailed(APIError)`
- User-friendly `errorDescription` on every case
- Never silently swallow errors

## Module Structure

New modules follow this exact structure:
```
Modules/[Name]/
├── Domain/Entities/, ValueObjects/, Repositories/, UseCases/, Errors/
├── Data/Repositories/, APIClient/, DTOs/, Mappers/, LocalStorage/
├── Presentation/Coordinator/, State/, Views/Components/
├── DI/[Name]ModuleDIContainer.swift
└── Tests/Domain/, Data/Mocks/, Presentation/, Integration/
```

## FORBIDDEN

- ❌ No ViewModel naming when using Coordinator pattern
- ❌ No SwiftUI imports in Domain layer
- ❌ No views creating other views directly
- ❌ No completion handlers (use async/await)
- ❌ No force unwraps in production code
- ❌ No DTOs in Domain layer
- ❌ No skipping tests for new code
- ❌ No implementing features without an OpenSpec proposal
