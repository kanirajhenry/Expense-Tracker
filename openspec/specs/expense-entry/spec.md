## ADDED Requirements

### Requirement: User can add a new expense
The system SHALL provide a form allowing the user to record a new expense with amount, category, date, and an optional note.

#### Scenario: Successful expense submission
- **WHEN** the user enters a valid amount, selects a category, and taps "Save"
- **THEN** the expense SHALL be saved and the form SHALL reset to its default state

#### Scenario: Amount is required
- **WHEN** the user taps "Save" with an empty or zero amount field
- **THEN** the system SHALL display an inline validation error and SHALL NOT save the expense

#### Scenario: Category is required
- **WHEN** the user taps "Save" without selecting a category
- **THEN** the system SHALL display an inline validation error and SHALL NOT save the expense

#### Scenario: Date defaults to today
- **WHEN** the user opens the expense entry form
- **THEN** the date field SHALL default to the current date

#### Scenario: Note is optional
- **WHEN** the user submits the form without entering a note
- **THEN** the expense SHALL be saved successfully with an empty note

#### Scenario: Amount accepts decimals
- **WHEN** the user enters an amount with up to two decimal places (e.g., "12.50")
- **THEN** the system SHALL accept and store the exact value

### Requirement: Category selection from predefined list
The system SHALL present a fixed list of expense categories for selection: Food, Transport, Housing, Health, Entertainment, Shopping, Other.

#### Scenario: All categories available for selection
- **WHEN** the user taps the category picker
- **THEN** the system SHALL display all seven predefined categories

#### Scenario: Only one category selected at a time
- **WHEN** the user selects a new category
- **THEN** the previously selected category SHALL be deselected
