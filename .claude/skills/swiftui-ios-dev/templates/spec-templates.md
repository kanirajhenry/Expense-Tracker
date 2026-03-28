# Spec Templates for iOS Modules

These templates guide OpenSpec when generating planning artifacts for iOS features. Copy the relevant sections into your `openspec/` customization or use them as mental models for what good iOS specs look like.

---

## proposal.md Template

```markdown
# Proposal: [Feature Name]

## Intent
[Why are we building this? What problem does it solve?]

## Scope

### In Scope
- [Feature 1]
- [Feature 2]

### Out of Scope
- [Explicitly excluded thing 1]
- [Explicitly excluded thing 2]

## Module
- **Module Name**: [Name]
- **Aggregate Root**: [Entity name] — [brief description]
- **Value Objects**: [List any VOs needed]
- **Screens**: [List screens this feature adds/modifies]

## User Stories

### Story 1: [Title]
As a [user type], I want to [action] so that [benefit].

**Acceptance Criteria:**
- Given [precondition], When [action], Then [result]
- Given [precondition], When [action], Then [result]

### Story 2: [Title]
...

## Dependencies
- [Other modules this depends on, if any]
- [APIs or services needed]

## Risks
- [Risk 1 and mitigation]
```

---

## specs/ Template (per feature)

```markdown
# Spec: [Feature Name]

## Requirements

### MUST (Required)
- [REQ-001] The system MUST [requirement]
- [REQ-002] The system MUST [requirement]

### SHOULD (Recommended)
- [REQ-003] The system SHOULD [requirement]

### MUST NOT (Forbidden)
- [REQ-004] The system MUST NOT [anti-requirement]

## Scenarios

### Scenario 1: [Happy Path]
- **Given**: [precondition]
- **When**: [action]
- **Then**: [expected result]

### Scenario 2: [Error Case]
- **Given**: [precondition]
- **When**: [action that fails]
- **Then**: [error handling behavior]

### Scenario 3: [Edge Case]
- **Given**: [boundary condition]
- **When**: [action]
- **Then**: [expected behavior at boundary]

## Data Model

### [Entity Name] (Aggregate Root)
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| id | UUID | Yes | Unique identifier |
| ... | ... | ... | ... |

### [Value Object Name]
| Property | Type | Description |
|----------|------|-------------|
| ... | ... | ... |

### Domain Methods
| Method | Parameters | Returns | Business Rule |
|--------|-----------|---------|---------------|
| ... | ... | ... | ... |

## Error Cases
| Error | Trigger | User Message |
|-------|---------|-------------|
| ... | ... | ... |
```

---

## design.md Template

```markdown
# Design: [Feature Name]

## Architecture

This module follows [ARCHITECTURE_FROM_PROJECT_MD] pattern.

### Layer Breakdown

#### Domain Layer
- **Aggregate Root**: `[Name]` — [what it represents]
  - Properties: [list key properties]
  - Domain Methods: [list business rules]
- **Value Objects**: [list with purpose]
- **Repository Protocol**: `[Name]Repository` — [what data operations]
- **UseCase**: `[Name]UseCase` — [what orchestration]
- **Error Type**: `[Name]Error` — [what error cases]

#### Data Layer
- **Repository Impl**: `[Name]RepositoryImpl`
  - Primary source: [API / Local Storage / Both]
  - Fallback: [Cache strategy if any]
- **API Endpoints**: [list endpoints with HTTP methods]
- **DTO**: `[Name]DTO` — maps to/from API JSON
- **Mapper**: `[Name]DTOMapper` — handles conversion + validation
- **Local Storage**: [if needed, which approach]

#### Presentation Layer
- **Coordinator**: `[Name]Coordinator`
  - Navigation flow: [describe screen transitions]
  - View creation: [which views it creates]
- **State Holder**: `[Name]State`
  - Published state: [list @Published properties]
  - Actions: [list user-facing methods]
  - Combine usage: [debouncing? reactive filtering?]
- **Views**:
  - `[Name]ListView` — [description]
  - `[Name]DetailView` — [description]
  - Components: [list reusable sub-views]

#### DI Container
- `[Name]ModuleDIContainer`
  - Creates: Repository → UseCase → State → Coordinator
  - Accepts: `APIClientProtocol` for testability
  - Provides: `.preview()` factory for SwiftUI previews

### Navigation Flow
```
[Name]Coordinator
├── make[Name]ListView()
│   └── navigateTo[Name]Detail(item)
│       └── make[Name]DetailView(item)
└── Sheets: [list sheet presentations]
```

### Cross-Module Integration
- [How this module communicates with existing modules]
- [Delegate protocols if any]

## Alternatives Considered
- **[Alternative 1]**: [Why rejected]
- **[Alternative 2]**: [Why rejected]
```

---

## tasks.md Template

```markdown
# Tasks: [Feature Name]

## Phase 1: Domain Layer
<!-- TDD: Write tests FIRST if TDD approach is chosen -->

- [ ] 1.1 Create `[Name]` aggregate root with domain methods
- [ ] 1.2 Create value objects: [list each VO]
- [ ] 1.3 Create `[Name]Repository` protocol
- [ ] 1.4 Create `[Name]UseCase` with business orchestration
- [ ] 1.5 Create `[Name]Error` enum
- [ ] 1.6 Write `[Name]AggregateTests`
- [ ] 1.7 Write `[ValueObject]Tests`

## Phase 2: Data Layer

- [ ] 2.1 Create `[Name]APIEndpoint` enum
- [ ] 2.2 Create `[Name]DTO` and `[Name]APIResponse`
- [ ] 2.3 Create `[Name]DTOMapper` with toDomain/toDTO
- [ ] 2.4 Create `[Name]RepositoryImpl`
- [ ] 2.5 Create `[Name]LocalStorage` (if needed)
- [ ] 2.6 Write `[Name]RepositoryTests` with MockAPIClient
- [ ] 2.7 Write `[Name]DTOMapperTests`

## Phase 3: Presentation Layer

- [ ] 3.1 Create `[Name]State` (state holder) with published properties
- [ ] 3.2 Create `[Name]Coordinator` with navigation + view factory
- [ ] 3.3 Create `[Name]ListView` with loading/error/empty states
- [ ] 3.4 Create `[Name]DetailView` (if needed)
- [ ] 3.5 Create reusable components: [Name]RowView, etc.
- [ ] 3.6 Write `[Name]StateTests`
- [ ] 3.7 Write `[Name]CoordinatorTests`

## Phase 4: Integration

- [ ] 4.1 Create `[Name]ModuleDIContainer`
- [ ] 4.2 Register module in AppDIContainer / RootCoordinator
- [ ] 4.3 Add tab/navigation entry point
- [ ] 4.4 Write integration test
- [ ] 4.5 Verify all tests pass (>80% coverage)

## Phase 5: Review

- [ ] 5.1 Verify Domain layer has zero framework imports
- [ ] 5.2 Verify all files have proper access control
- [ ] 5.3 Verify all views have #Preview blocks
- [ ] 5.4 Verify no force unwraps in production code
- [ ] 5.5 Verify naming follows project conventions
```

---

## Tips for Better Specs

1. **Be specific in scope** — "Add cart" is vague. "Add cart module with add/remove items, quantity update, price calculation, and checkout validation" is actionable.

2. **Include error scenarios** — Every spec should have at least 2 error scenarios (network failure, invalid data).

3. **Define boundaries** — "Out of Scope" is as important as "In Scope". Prevents AI from gold-plating.

4. **Reference existing patterns** — "Follow the same pattern as the Product module" tells the AI to look at existing code for conventions.

5. **Tasks should be atomic** — Each task = one commit. "Create CartState with all methods" is better than "Build the entire presentation layer".
