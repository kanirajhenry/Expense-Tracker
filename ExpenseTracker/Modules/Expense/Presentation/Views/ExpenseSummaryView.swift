import SwiftUI

struct ExpenseSummaryView: View {
    let state: ExpenseSummaryState

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Total
                Section("Total Spending") {
                    HStack {
                        Text("Total")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(state.totalFormatted)
                            .font(.title2.monospacedDigit())
                            .fontWeight(.bold)
                    }
                }

                // MARK: - Category breakdown
                if !state.categoryBreakdown.isEmpty {
                    Section("By Category") {
                        ForEach(state.categoryBreakdown, id: \.0) { category, total in
                            HStack {
                                Text(category.rawValue)
                                Spacer()
                                Text(total)
                                    .foregroundStyle(.secondary)
                                    .font(.body.monospacedDigit())
                            }
                        }
                    }
                }

                // MARK: - Recent expenses
                if !state.recentExpenses.isEmpty {
                    Section("Recent") {
                        ForEach(state.recentExpenses) { expense in
                            ExpenseRowView(expense: expense)
                        }
                    }
                }
            }
            .navigationTitle("Summary")
        }
        .task { await state.load() }
    }
}

#Preview {
    let state = ExpenseSummaryState(useCase: PreviewExpenseManagementUseCase())
    return ExpenseSummaryView(state: state)
}
