## ADDED Requirements

### Requirement: Total spending displayed
The system SHALL display the sum of all recorded expense amounts as the overall total.

#### Scenario: Total reflects all expenses
- **WHEN** the user views the Summary tab
- **THEN** the system SHALL display the sum of all expense amounts formatted as currency

#### Scenario: Total updates after new expense
- **WHEN** the user adds a new expense
- **THEN** the total on the Summary tab SHALL reflect the updated sum

#### Scenario: Total is zero with no expenses
- **WHEN** no expenses have been recorded
- **THEN** the total SHALL display as $0.00

### Requirement: Per-category spending breakdown
The system SHALL display a breakdown of total spending grouped by category.

#### Scenario: Each used category shown with its total
- **WHEN** expenses exist across multiple categories
- **THEN** the summary SHALL list each category alongside its total spend

#### Scenario: Unused categories are hidden
- **WHEN** no expenses exist for a given category
- **THEN** that category SHALL NOT appear in the breakdown

#### Scenario: Category totals equal overall total
- **WHEN** the user views the summary
- **THEN** the sum of all category totals SHALL equal the overall total

### Requirement: Five most recent expenses shown
The system SHALL display the five most recent expenses on the summary screen.

#### Scenario: Recent list capped at five
- **WHEN** more than five expenses exist
- **THEN** the summary SHALL show only the five most recent expenses ordered by date descending

#### Scenario: Fewer than five expenses shows all
- **WHEN** fewer than five expenses exist
- **THEN** all expenses SHALL be shown in the recent expenses section
