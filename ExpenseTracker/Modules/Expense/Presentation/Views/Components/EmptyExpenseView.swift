import SwiftUI

struct EmptyExpenseView: View {
    var body: some View {
        ContentUnavailableView(
            "No Expenses Yet",
            systemImage: "tray",
            description: Text("Tap the Add tab to record your first expense.")
        )
    }
}

#Preview {
    EmptyExpenseView()
}
