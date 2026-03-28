---
name: swiftui-ios-dev
description: >
  Universal iOS application development skill using Spec-Driven Development with SwiftUI.
  Use this skill whenever the user asks to create, build, develop, scaffold, or architect an
  iOS app, iPhone app, iPad app, or Apple mobile application. Trigger when the user describes
  ANY app idea and wants to build it for iOS. Also trigger when the user wants to analyze an
  existing iOS/Swift project to understand its architecture, add features, refactor, or write
  tests. Trigger for questions about iOS project structure, architecture decisions, SwiftUI
  patterns, Swift testing, dependency injection, navigation, state management, networking,
  or module design. Even if the user just says "build me an app" or "new iOS project" — use
  this skill. Also trigger when the user mentions OpenSpec, spec-driven development, or wants
  to generate a project specification before coding.
---

# Universal SwiftUI iOS Development Skill

Build any iOS application through Spec-Driven Development (SDD) using OpenSpec + Claude Code. The developer chooses the architecture, patterns, paradigm, and tools — the skill adapts to those choices and generates production-ready code from structured specs.

---

## Spec-Driven Development with OpenSpec

This skill is designed to work with **OpenSpec** — a spec-driven development framework for AI coding assistants. The workflow is: **agree on what to build → write specs → generate code from specs**.

For full OpenSpec setup and workflow details, read `references/openspec-integration.md`.

### Three Modes of Operation

**Mode A: New Project (Fresh Start)**
1. Initialize OpenSpec → set up `project.md` and `CLAUDE.md`
2. Developer chooses tech stack (Step 2 below)
3. Use `/opsx:propose` to plan each module
4. Use `/opsx:apply` to implement from specs
5. Use `/opsx:archive` when done

**Mode B: Existing Project (Add Features)**
1. Analyze the codebase → detect architecture, patterns, testing
2. Initialize OpenSpec if not already set up
3. Use `/opsx:propose` to plan new features
4. Use `/opsx:apply` to implement following existing patterns
5. Use `/opsx:archive` when done

**Mode C: Without OpenSpec (Direct Development)**
1. Developer describes the app and chooses tech stack
2. Skip spec artifacts — generate code directly
3. Same architecture and pattern quality, just without the spec layer

For Mode A and B, generate the `project.md` and `CLAUDE.md` files from the templates in `templates/`. These files ensure OpenSpec and Claude Code understand your iOS conventions.

### OpenSpec Project Setup

When starting a new project or adding OpenSpec to an existing one:

1. Read `references/openspec-integration.md` for installation steps
2. Generate `openspec/project.md` from `templates/project.md` — fill in the developer's tech stack choices
3. Generate `CLAUDE.md` from `templates/CLAUDE.md` — fill in architecture rules
4. Use `templates/spec-templates.md` for iOS-specific proposal/design/tasks templates

### Template Files

| Template | Purpose | Where It Goes |
|----------|---------|--------------|
| `templates/project.md` | Tech stack + architecture rules for OpenSpec | `openspec/project.md` |
| `templates/CLAUDE.md` | Persistent Claude Code instructions | Project root `CLAUDE.md` |
| `templates/spec-templates.md` | iOS module proposal/design/tasks patterns | Reference for spec generation |

---

## Step 1: Project Spec (Mode A — New Project)

Before any tech decisions, capture WHAT the app does:

1. **App name & purpose** — What does the app do? (1–2 sentences)
2. **Target iOS version** — Default: iOS 17+
3. **Key features / modules** — Main feature areas (e.g., "product listing, cart, user profile")
4. **Entities** — Core data objects per module (e.g., Product, Cart, User)
5. **Screens** — Key screens per module (e.g., list, detail, form)
6. **Data sources** — Remote API, local storage, or both?
7. **Authentication** — Needed? What kind?
8. **Third-party libraries** — Any specific ones?

From the feature list, derive **modules**. Each module = a distinct feature area with its own entity, screens, and business rules.

---

## Step 2: Developer Tech Stack Choices

Present these choices to the developer. Each choice maps to a specific reference file section.

### Choice 1: Architecture Pattern
Ask: "Which architecture pattern do you want to use?"

| Option | Best For | Reference |
|--------|----------|-----------|
| **Coordinator Pattern + Aggregate Model** | Navigation-heavy apps, rich domain models | `references/architectures.md` → Coordinator |
| **MVVM** | Simple-to-medium SwiftUI apps, reactive data flow | `references/architectures.md` → MVVM |
| **Clean Architecture** | Large-scale apps, complex business logic, multiple data sources | `references/architectures.md` → Clean Architecture |
| **VIPER** | Enterprise apps, strict modular separation, large teams | `references/architectures.md` → VIPER |
| **MVC** | Prototypes, very simple apps, learning projects | `references/architectures.md` → MVC |

### Choice 2: Programming Paradigm
Ask: "Which paradigm?"

| Option | What It Means | Reference |
|--------|--------------|-----------|
| **Protocol-Oriented Programming (POP)** | Protocols + extensions + composition over inheritance | `references/swift-paradigms.md` → POP |
| **Object-Oriented Programming (OOP)** | Classes + inheritance + polymorphism | `references/swift-paradigms.md` → OOP |
| **Hybrid (POP + OOP)** | Protocols for abstractions, classes where reference semantics needed | `references/swift-paradigms.md` → Hybrid |

### Choice 3: Use Generics?
Ask: "Should the codebase use Swift generics for reusable components?"

| Option | Reference |
|--------|-----------|
| **Yes — Generic APIClient, Generic Repository, Generic Views** | `references/swift-paradigms.md` → Generics |
| **No — Concrete types per module** | Skip generics section |

### Choice 4: Design Patterns
Ask: "Which design patterns?" (multiple selection)

| Option | What It Does | Reference |
|--------|-------------|-----------|
| **Repository Pattern** | Abstracts data access behind protocols | `references/design-patterns.md` → Repository |
| **DI Container** | Centralized dependency assembly per module | `references/design-patterns.md` → DI Container |
| **Factory Pattern** | Encapsulates object creation | `references/design-patterns.md` → Factory |
| **Service Locator** | Runtime dependency resolution | `references/design-patterns.md` → Service Locator |
| **Singleton** | Shared instances (use sparingly) | `references/design-patterns.md` → Singleton |

### Choice 5: State Management
Ask: "How should UI state be managed?"

| Option | What It Means | Reference |
|--------|--------------|-----------|
| **State Holder + Combine** | Explicit state class with @Published, NOT ViewModel | `references/design-patterns.md` → State Holder |
| **ViewModel + @Observable** | iOS 17+ @Observable macro, modern approach | `references/design-patterns.md` → ViewModel Observable |
| **ViewModel + ObservableObject** | iOS 15–16 compatible, @Published properties | `references/design-patterns.md` → ViewModel ObservableObject |

### Choice 6: Networking
Ask: "How should networking be handled?"

| Option | Reference |
|--------|-----------|
| **URLSession (custom wrapper, no third-party)** | `references/networking.md` → URLSession |
| **Alamofire** | `references/networking.md` → Alamofire |
| **Moya (Alamofire-based)** | `references/networking.md` → Moya |

### Choice 7: Concurrency
Ask: "Which concurrency approach?"

| Option | Reference |
|--------|-----------|
| **async/await (modern)** | `references/networking.md` → async/await |
| **Combine (reactive)** | `references/networking.md` → Combine |
| **GCD (traditional)** | `references/networking.md` → GCD |

### Choice 8: Testing Framework
Ask: "Which testing framework?"

| Option | Reference |
|--------|-----------|
| **Swift Testing (@Test, #expect)** | `references/testing.md` → Swift Testing |
| **XCTest (XCTAssert, XCTestCase)** | `references/testing.md` → XCTest |

### Choice 9: Testing Approach
Ask: "What testing approach?"

| Option | Reference |
|--------|-----------|
| **TDD (tests first, then implementation)** | `references/testing.md` → TDD |
| **Test After (implement first, then write tests)** | `references/testing.md` → Test After |
| **No Tests** | Skip testing reference |

### Choice 10: Local Persistence
Ask: "How should local data be stored?" (if needed)

| Option | Reference |
|--------|-----------|
| **SwiftData (iOS 17+)** | `references/persistence.md` → SwiftData |
| **Core Data** | `references/persistence.md` → Core Data |
| **UserDefaults + Codable** | `references/persistence.md` → UserDefaults |
| **Realm** | `references/persistence.md` → Realm |
| **None** | Skip persistence |

---

## Step 3: Load Reference Files

Based on the developer's choices, read ONLY the relevant reference files and sections. Do not load files for unchosen options.

| Reference File | What It Contains |
|----------------|-----------------|
| `references/architectures.md` | Folder structures, layer separation, navigation patterns for each architecture |
| `references/design-patterns.md` | Repository, DI Container, Factory, State Holder, ViewModel patterns |
| `references/swift-paradigms.md` | POP, OOP, Generics — protocol design, composition, generic templates |
| `references/testing.md` | Swift Testing vs XCTest, TDD workflow, mock patterns, coverage targets |
| `references/networking.md` | URLSession client, Alamofire, API endpoint patterns, async/await vs Combine |
| `references/persistence.md` | SwiftData, Core Data, UserDefaults+Codable, Realm templates |
| `references/openspec-integration.md` | OpenSpec setup, workflow commands, iOS-specific spec workflow |

### Template Files (for OpenSpec setup)

| Template | What It Contains |
|----------|-----------------|
| `templates/project.md` | OpenSpec project definition with iOS tech stack placeholders |
| `templates/CLAUDE.md` | Claude Code persistent instructions with iOS conventions |
| `templates/spec-templates.md` | iOS module proposal.md, design.md, specs/, tasks.md templates |

---

## Step 4: Analyze Existing Project (Mode B)

When the user has an existing project, detect the tech stack by examining:

1. **Folder structure** — Modules/, Features/, MVVM folders? Coordinator files?
2. **Import statements** — `import Combine`, `import Alamofire`, `import RealmSwift`?
3. **Class patterns** — `ObservableObject` = ViewModel, `@Observable` = modern, custom State class?
4. **Protocol usage** — Heavy protocols = POP, class hierarchies = OOP?
5. **Test files** — `@Test` = Swift Testing, `XCTestCase` = XCTest?
6. **Networking** — `URLSession` wrapper? Alamofire? Moya?
7. **Navigation** — Coordinator classes? NavigationStack? NavigationView?
8. **DI** — Container classes? Property injection? Environment injection?

After detection, tell the user: "I've detected your project uses [architecture] with [patterns]. I'll follow these patterns for any new code."

Then load the matching reference files and generate code consistently.

---

## Step 5: Generate Module Code

For each module, generate code following the developer's chosen patterns. The exact folder structure comes from the architecture reference file.

### Universal Module Structure (adapts to architecture choice)

Every module, regardless of architecture, has these conceptual layers:

```
[ModuleName]/
├── Domain/          # Business logic (entities, rules, protocols)
├── Data/            # External interactions (API, storage, mapping)
├── Presentation/    # UI (views, state/viewmodel, navigation)
├── DI/              # Dependency wiring
└── Tests/           # Test suite
```

The exact files inside each folder depend on the architecture and pattern choices. Read the architecture reference file for the specific structure.

### Code Generation Checklist

Before delivering code, verify against the developer's choices:

- [ ] Architecture matches chosen pattern (folder structure, navigation, layer separation)
- [ ] Paradigm matches (POP = protocols everywhere, OOP = class hierarchies, Hybrid = mix)
- [ ] State management matches (State Holder vs ViewModel vs @Observable)
- [ ] Networking matches (URLSession vs Alamofire, async/await vs Combine)
- [ ] Testing matches (Swift Testing vs XCTest, TDD order vs Test After)
- [ ] Correct imports (no unnecessary frameworks in Domain layer)
- [ ] `#Preview` block on every SwiftUI view
- [ ] Access control applied (`private` by default)
- [ ] No force unwraps except known-safe constants
- [ ] Error handling uses module-specific error enums
- [ ] DI Container wires all dependencies (if DI Container chosen)
- [ ] File names match their primary type name
- [ ] `// MARK: -` comments in files > 50 lines
- [ ] Code is production-ready, not pseudo-code
- [ ] All SOLID principles applied (if chosen)

---

## Swift Style Rules (Always Applied)

These rules apply regardless of architecture or pattern choices:

### Language & Syntax
- Use latest stable Swift features appropriate for the target iOS version
- Prefer `let` over `var` — immutability first
- Use `guard` for early returns, `if let` for optional binding
- Mark classes `final` unless designed for inheritance
- Use `private` by default, widen access only when needed
- `// MARK: -` to organize files with 50+ lines
- Trailing closure syntax
- Avoid force unwrapping (`!`) except for known-safe constants

### Naming Conventions
- **Entities**: `Product`, `User`, `Order` (clean nouns)
- **Protocols**: PascalCase — `ProductRepository`, `Networking`, `Authenticable`
- **Views**: suffix with `View` — `HomeView`, `ProductListView`
- **Tests**: suffix with `Tests` — `ProductTests`, `CartStateTests`
- **Mocks**: prefix with `Mock` — `MockProductRepository`, `MockAPIClient`
- **DTOs**: suffix with `DTO` — `ProductDTO`, `UserDTO`
- **Mappers**: suffix with `Mapper` — `ProductDTOMapper`
- **Extensions**: `Type+Purpose.swift` — `Date+Formatting.swift`
- **Files match their primary type name**

### Error Handling
- Define module-specific error enums
- Use `LocalizedError` for user-facing messages
- Wrap lower-level errors in domain errors
- Never silently swallow errors

### Access Control
- Default everything to `private`
- Mark `public` only at module boundaries
- Use `private(set)` for read-only published properties
- Implementation details are always `private`
