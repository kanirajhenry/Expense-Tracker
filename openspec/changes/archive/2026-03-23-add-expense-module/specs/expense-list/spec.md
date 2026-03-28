## ADDED Requirements

### Requirement: Expenses displayed in a scrollable list
The system SHALL display all recorded expenses in a list sorted by date descending (most recent first), showing amount, category, and date for each row.

#### Scenario: List shows all expenses
- **WHEN** the user navigates to the Expenses tab
- **THEN** the system SHALL display all saved expenses sorted by date descending

#### Scenario: Empty state when no expenses exist
- **WHEN** no expenses have been recorded
- **THEN** the system SHALL display an empty state message prompting the user to add their first expense

#### Scenario: List updates immediately after new expense is added
- **WHEN** the user saves a new expense
- **THEN** the expense SHALL appear in the list without requiring a manual refresh

### Requirement: User can delete an expense
The system SHALL allow the user to permanently delete an expense via swipe-to-delete.

#### Scenario: Swipe to delete removes expense
- **WHEN** the user swipes left on an expense row and confirms deletion
- **THEN** the expense SHALL be permanently removed from the list and from persistent storage

#### Scenario: Deletion is irreversible
- **WHEN** the user confirms deletion
- **THEN** the expense SHALL be removed with no undo option

### Requirement: List can be filtered by category
The system SHALL allow the user to filter the expense list to show only expenses matching a selected category.

#### Scenario: Filter shows only matching expenses
- **WHEN** the user selects a category filter
- **THEN** the list SHALL display only expenses whose category matches the selected filter

#### Scenario: Selecting All clears the filter
- **WHEN** the user selects the "All" filter option
- **THEN** the list SHALL display all expenses regardless of category
