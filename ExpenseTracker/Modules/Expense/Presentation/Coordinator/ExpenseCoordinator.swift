import SwiftUI
import Observation

@Observable
@MainActor
final class ExpenseCoordinator {

    // MARK: - State holders (owned by coordinator)

    private let listState: ExpenseListState
    private let addState: AddExpenseState
    private let summaryState: ExpenseSummaryState

    // MARK: - Navigation

    var selectedTab: Tab = .list

    enum Tab: Int {
        case list    = 0
        case add     = 1
        case summary = 2
    }

    // MARK: - Init

    init(
        listState: ExpenseListState,
        addState: AddExpenseState,
        summaryState: ExpenseSummaryState
    ) {
        self.listState = listState
        self.addState = addState
        self.summaryState = summaryState
    }

    // MARK: - View factory

    func makeExpenseListView() -> some View {
        ExpenseListView(state: listState)
    }

    func makeAddExpenseView() -> some View {
        AddExpenseView(state: addState)
    }

    func makeExpenseSummaryView() -> some View {
        ExpenseSummaryView(state: summaryState)
    }

    // MARK: - Root view

    func makeRootView() -> some View {
        TabView(selection: Bindable(self).selectedTab) {
            makeExpenseListView()
                .tabItem { Label("Expenses", systemImage: "list.bullet") }
                .tag(Tab.list)

            makeAddExpenseView()
                .tabItem { Label("Add", systemImage: "plus.circle") }
                .tag(Tab.add)

            makeExpenseSummaryView()
                .tabItem { Label("Summary", systemImage: "chart.pie") }
                .tag(Tab.summary)
        }
    }
}
