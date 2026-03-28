//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Kaniraj Henry on 23-03-2026.
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {

    @State private var container = ExpenseModuleDIContainer()

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
        }
        .modelContainer(container.modelContainer)
    }
}

// MARK: - AppRootView

private struct AppRootView: View {
    let container: ExpenseModuleDIContainer
    @State private var coordinator: ExpenseCoordinator?

    var body: some View {
        if let coordinator {
            coordinator.makeRootView()
        } else {
            ProgressView()
                .task { coordinator = container.makeCoordinator() }
        }
    }
}
