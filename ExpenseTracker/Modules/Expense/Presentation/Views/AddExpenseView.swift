import SwiftUI

struct AddExpenseView: View {
    let state: AddExpenseState

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Amount
                Section("Amount") {
                    TextField("0.00", text: Bindable(state).amountText)
                        .keyboardType(.decimalPad)
                }

                // MARK: - Category
                Section("Category") {
                    Picker("Category", selection: Bindable(state).selectedCategory) {
                        Text("Select a category").tag(ExpenseCategory?.none)
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(ExpenseCategory?.some(category))
                        }
                    }
                    .pickerStyle(.menu)
                }

                // MARK: - Date
                Section("Date") {
                    DatePicker("Date", selection: Bindable(state).date, displayedComponents: .date)
                        .labelsHidden()
                }

                // MARK: - Note
                Section("Note (optional)") {
                    TextField("Add a note…", text: Bindable(state).note)
                }

                // MARK: - Validation error
                if let error = state.validationError {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await state.save() }
                    }
                    .disabled(state.isSaving)
                }
            }
            .overlay {
                if state.isSaving {
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    AddExpenseView(state: AddExpenseState(useCase: PreviewExpenseManagementUseCase()))
}
