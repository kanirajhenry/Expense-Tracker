import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category.rawValue)
                    .font(.headline)
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(expense.amount.formatted())
                .font(.body.monospacedDigit())
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        ForEach(Expense.sampleList) { expense in
            ExpenseRowView(expense: expense)
        }
    }
}
