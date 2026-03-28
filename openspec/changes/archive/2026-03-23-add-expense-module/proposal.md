## Why

The ExpenseTracker app currently has no core functionality — only a default placeholder view. Users need a way to log, categorize, and review their personal expenses, which is the foundational capability the app exists to provide.

## What Changes

- Replace the placeholder `ContentView` with a tab-based navigation shell
- Add the ability to create new expense entries (amount, category, date, optional note)
- Add a list view to display, filter, and delete recorded expenses
- Add a summary view showing total spending and per-category breakdowns
- Add local persistence so expenses survive app restarts

## Capabilities

### New Capabilities

- `expense-entry`: Form-based UI for creating individual expense records (amount, category, date, note)
- `expense-list`: Scrollable list displaying all expenses with swipe-to-delete and category filtering
- `expense-summary`: Dashboard showing total spend, per-category breakdown, and recent activity
- `expense-persistence`: Local data storage for expense records using SwiftData

### Modified Capabilities

<!-- No existing specs — this is the first feature module -->

## Impact

- Replaces `ContentView.swift` body with a `TabView` navigation shell
- Introduces SwiftData model layer (`Expense` model, `CategoryType` enum)
- Adds new SwiftUI views: `ExpenseEntryView`, `ExpenseListView`, `ExpenseSummaryView`
- Requires iOS 17+ deployment target (SwiftData dependency)
- No external package dependencies
