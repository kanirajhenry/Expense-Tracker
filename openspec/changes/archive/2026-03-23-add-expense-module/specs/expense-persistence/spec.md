## ADDED Requirements

### Requirement: Expenses persisted across app launches
The system SHALL store all expense records locally so they survive app termination and restart.

#### Scenario: Expense survives app restart
- **WHEN** the user records an expense and restarts the app
- **THEN** the expense SHALL still appear in the list

#### Scenario: Deleted expense does not reappear after restart
- **WHEN** the user deletes an expense and restarts the app
- **THEN** the deleted expense SHALL NOT reappear

### Requirement: Expense model stores all required fields
The system SHALL persist each expense with the following fields: unique identifier (UUID), amount (Double), category (String), date (Date), and note (String).

#### Scenario: All fields stored and retrieved without data loss
- **WHEN** an expense is saved with all fields populated
- **THEN** all field values SHALL be retrievable with the same values and types

#### Scenario: Note defaults to empty string when omitted
- **WHEN** an expense is saved without a note
- **THEN** the note field SHALL be stored and returned as an empty string

### Requirement: SwiftData used as the persistence layer
The system SHALL use SwiftData with the `@Model` macro on the `Expense` class and inject a `ModelContainer` into the SwiftUI environment at app startup.

#### Scenario: ModelContext available to all views
- **WHEN** the app launches
- **THEN** all views SHALL have access to a SwiftData `ModelContext` via the SwiftUI environment
