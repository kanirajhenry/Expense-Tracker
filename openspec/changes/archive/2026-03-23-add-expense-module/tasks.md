## 1. Project & Module Scaffold

- [x] 1.1 Set iOS deployment target to 17.0 in Xcode project settings
- [x] 1.2 Create the full module folder structure under `ExpenseTracker/Modules/Expense/` with subfolders: `Domain/Entities`, `Domain/ValueObjects`, `Domain/Repositories`, `Domain/UseCases`, `Domain/Errors`, `Data/Repositories`, `Data/SwiftDataModels`, `Data/Mappers`, `Data/LocalStorage`, `Presentation/Coordinator`, `Presentation/State`, `Presentation/Views/Components`, `DI`, `Tests/Domain`, `Tests/Data/Mocks`, `Tests/Presentation`, `Tests/Integration`

## 2. Domain Layer — Value Objects (TDD)

- [x] 2.1 Write `Tests/Domain/ExpenseCategoryTests.swift`: `@Suite` with `@Test` cases verifying all seven cases (Food, Transport, Housing, Health, Entertainment, Shopping, Other), `CaseIterable` count, and `rawValue` strings
- [x] 2.2 Create `Domain/ValueObjects/ExpenseCategory.swift`: `CaseIterable` enum with `String` raw values matching the seven predefined categories
- [x] 2.3 Write `Tests/Domain/MoneyTests.swift`: tests for `Money` equality, zero guard (amount must be > 0), and `formatted(locale:)` output
- [x] 2.4 Create `Domain/ValueObjects/Money.swift`: immutable struct with `amount: Double` and `formatted(locale: Locale) -> String` using `NumberFormatter`; add static `.zero` and `.preview` fixtures

## 3. Domain Layer — Aggregate Root & Error (TDD)

- [x] 3.1 Write `Tests/Domain/ExpenseAggregateTests.swift`: `@Suite` with `@Test` cases for `Expense` initialization, immutability, and static `.preview` / `.sampleList` fixture values
- [x] 3.2 Create `Domain/Entities/Expense.swift`: pure Swift `struct` with `id: UUID`, `amount: Money`, `category: ExpenseCategory`, `date: Date`, `note: String`; add `static let preview` and `static let sampleList` fixtures; NO framework imports
- [x] 3.3 Create `Domain/Errors/ExpenseError.swift`: `enum ExpenseError: LocalizedError` with cases `invalidAmount`, `missingCategory`, `saveFailed`, `deleteFailed`, `fetchFailed`

## 4. Domain Layer — Repository Protocol & Use Case (TDD)

- [x] 4.1 Create `Domain/Repositories/ExpenseRepository.swift`: `protocol ExpenseRepository` with `async throws` methods: `save(_ expense: Expense)`, `delete(id: UUID)`, `fetchAll() -> [Expense]`, `fetch(category: ExpenseCategory) -> [Expense]`
- [x] 4.2 Create `Domain/UseCases/ExpenseManagementUseCaseProtocol.swift`: protocol mirroring `ExpenseManagementUseCase`'s public interface
- [x] 4.3 Write `Tests/Data/Mocks/MockExpenseRepository.swift`: `final class MockExpenseRepository: ExpenseRepository` with call-count tracking (`saveCallCount`, `deleteCallCount`, etc.), stored results, and a `shouldFail: Bool` flag that throws `ExpenseError` on any operation
- [x] 4.4 Write `Tests/Domain/ExpenseManagementUseCaseTests.swift`: `@Suite` using `MockExpenseRepository` — test `addExpense` validates amount > 0 (throws `invalidAmount`), test `addExpense` validates category selected, test `deleteExpense` calls repository, test `fetchAll` returns mapped results, test `fetch(category:)` filters correctly
- [x] 4.5 Create `Domain/UseCases/ExpenseManagementUseCase.swift`: `final class ExpenseManagementUseCase: ExpenseManagementUseCaseProtocol` injecting `any ExpenseRepository`; implement `addExpense(amount:category:date:note:)` with validation, `deleteExpense(id:)`, `fetchAllExpenses() async throws -> [Expense]`, `fetchExpenses(category:) async throws -> [Expense]`

## 5. Data Layer — SwiftData Model & Mapper (TDD)

- [x] 5.1 Create `Data/SwiftDataModels/ExpenseModel.swift`: `@Model final class ExpenseModel` with fields matching `Expense` (`id: UUID`, `amount: Double`, `categoryRaw: String`, `date: Date`, `note: String`); import SwiftData here only
- [x] 5.2 Write `Tests/Data/ExpenseModelMapperTests.swift`: `@Suite` verifying round-trip fidelity — `ExpenseModel → Expense → ExpenseModel` preserves all field values; test `categoryRaw` with unknown string maps to `.other`
- [x] 5.3 Create `Data/Mappers/ExpenseModelMapper.swift`: stateless `enum ExpenseModelMapper` with `static func toDomain(_ model: ExpenseModel) -> Expense` and `static func toModel(_ expense: Expense) -> ExpenseModel`

## 6. Data Layer — Local Storage & Repository Implementation (TDD)

- [x] 6.1 Create `Data/LocalStorage/ExpenseLocalStorage.swift`: `protocol ExpenseLocalStorageProtocol` + `final class ExpenseLocalStorage` wrapping `ModelContext` with `async` methods: `insert(_:)`, `delete(id:)`, `fetchAll() -> [ExpenseModel]`, `fetch(categoryRaw:) -> [ExpenseModel]`
- [x] 6.2 Write `Tests/Data/ExpenseRepositoryImplTests.swift`: integration tests using an in-memory `ModelContainer(for: ExpenseModel.self, configurations: .init(isStoredInMemoryOnly: true))`; verify insert, delete, fetchAll, fetch-by-category round trips
- [x] 6.3 Create `Data/Repositories/ExpenseRepositoryImpl.swift`: `final class ExpenseRepositoryImpl: ExpenseRepository` injecting `ExpenseLocalStorageProtocol` and `ExpenseModelMapper`; implement all protocol methods using `async/await`, mapping domain ↔ model via `ExpenseModelMapper`

## 7. Presentation Layer — State Holders (TDD)

- [x] 7.1 Write `Tests/Presentation/AddExpenseStateTests.swift`: `@Suite` using `MockExpenseRepository` (via mock use case) — test that tapping save with zero amount sets `validationError`, test successful save resets form fields, test `isSaving` toggles correctly around async call
- [x] 7.2 Create `Presentation/State/AddExpenseState.swift`: `@Observable final class AddExpenseState` with `amountText: String`, `selectedCategory: ExpenseCategory?`, `date: Date`, `note: String`, `validationError: String?`, `isSaving: Bool`; `func save() async` calls use case, throws mapped `ExpenseError`, resets on success
- [x] 7.3 Write `Tests/Presentation/ExpenseListStateTests.swift`: test `load()` populates `expenses`, test `delete(id:)` calls use case and removes from local array, test `selectedCategory` filter triggers re-fetch
- [x] 7.4 Create `Presentation/State/ExpenseListState.swift`: `@Observable final class ExpenseListState` with `expenses: [Expense]`, `selectedCategory: ExpenseCategory?`, `isLoading: Bool`, `error: ExpenseError?`; `func load() async`, `func delete(id: UUID) async`, category filter re-fetches on `selectedCategory` change
- [x] 7.5 Write `Tests/Presentation/ExpenseSummaryStateTests.swift`: test `totalFormatted` returns locale-aware currency string, test `categoryBreakdown` omits zero-total categories and sums correctly, test `recentExpenses` is capped at 5
- [x] 7.6 Create `Presentation/State/ExpenseSummaryState.swift`: `@Observable final class ExpenseSummaryState` with `expenses: [Expense]`, computed `totalFormatted: String`, `categoryBreakdown: [(ExpenseCategory, String)]`, `recentExpenses: [Expense]` (capped at 5); `func load() async`

## 8. Presentation Layer — Views & Coordinator

- [x] 8.1 Create `Presentation/Views/Components/ExpenseRowView.swift`: displays a single `Expense` row (formatted amount, category, date); add `#Preview`
- [x] 8.2 Create `Presentation/Views/Components/CategoryFilterView.swift`: segmented/picker control over `ExpenseCategory.allCases` plus "All"; add `#Preview`
- [x] 8.3 Create `Presentation/Views/Components/EmptyExpenseView.swift`: empty state message + call-to-action; add `#Preview`
- [x] 8.4 Create `Presentation/Views/ExpenseListView.swift`: receives `ExpenseListState` from coordinator; renders `List` with `ExpenseRowView`, swipe-to-delete calling `state.delete(id:)`, `CategoryFilterView` bound to `state.selectedCategory`, `EmptyExpenseView` when list is empty; `.task { await state.load() }`; add `#Preview`
- [x] 8.5 Create `Presentation/Views/AddExpenseView.swift`: receives `AddExpenseState` from coordinator; `Form` with amount `TextField` (`.keyboardType(.decimalPad)`), `CategoryType` `Picker`, `DatePicker`, note `TextField`, inline validation error label, Save `Button` calling `await state.save()`; add `#Preview`
- [x] 8.6 Create `Presentation/Views/ExpenseSummaryView.swift`: receives `ExpenseSummaryState` from coordinator; displays total, category breakdown list (hiding zero-total categories), recent expenses section; `.task { await state.load() }`; add `#Preview`
- [x] 8.7 Create `Presentation/Coordinator/ExpenseCoordinator.swift`: `@Observable final class ExpenseCoordinator`; owns `ExpenseListState`, `AddExpenseState`, `ExpenseSummaryState`; implements `makeExpenseListView()`, `makeAddExpenseView()`, `makeExpenseSummaryView()` factory methods; manages `TabView` tab selection; views are ONLY ever created here

## 9. DI Container & App Wiring

- [x] 9.1 Create `DI/ExpenseModuleDIContainer.swift`: assembles the full dependency graph — `ModelContainer`, `ExpenseLocalStorage`, `ExpenseRepositoryImpl`, `ExpenseManagementUseCase`, `ExpenseCoordinator`; exposes `makeCoordinator() -> ExpenseCoordinator`
- [x] 9.2 Update `ExpenseTrackerApp.swift`: instantiate `ExpenseModuleDIContainer`, call `makeCoordinator()`, replace `ContentView()` with a `TabView` shell built by the coordinator using its three view factory methods; inject `ModelContainer` into environment via `.modelContainer(...)`

## 10. Integration Tests & Final Verification

- [x] 10.1 Write `Tests/Integration/ExpenseModuleIntegrationTests.swift`: end-to-end test using in-memory `ModelContainer` — add expense via use case, fetch via repository, assert present; delete expense, fetch, assert absent
- [x] 10.2 Verify all `@Test` suites pass with no XCTest references anywhere in `Tests/`
- [x] 10.3 Verify Domain layer has zero imports of SwiftUI, SwiftData, or any framework
- [x] 10.4 Verify Presentation layer has zero imports of SwiftData or Data layer types
- [ ] 10.5 Run app on iOS 17 simulator: add expense → appears in list and summary; swipe-delete → removed everywhere; category filter → correct rows; restart → data persists
