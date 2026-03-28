import SwiftUI

struct ExpenseListView: View {
    let state: ExpenseListState

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CategoryFilterView(selectedCategory: Bindable(state).selectedCategory)
                    .padding(.vertical, 8)

                if state.expenses.isEmpty && !state.isLoading {
                    EmptyExpenseView()
                } else {
                    List {
                        ForEach(state.expenses) { expense in
                            ExpenseRowView(expense: expense)
                        }
                        .onDelete { indexSet in
                            Task {
                                for index in indexSet {
                                    await state.delete(id: state.expenses[index].id)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Expenses")
            .overlay {
                if state.isLoading {
                    ProgressView()
                }
            }
        }
        .task { await state.load() }
        .onChange(of: state.selectedCategory) {
            Task { await state.load() }
        }
    }
}

#Preview {
    let state = ExpenseListState(useCase: PreviewExpenseManagementUseCase())
    return ExpenseListView(state: state)
}
