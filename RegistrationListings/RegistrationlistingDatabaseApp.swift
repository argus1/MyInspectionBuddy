//
// RegistrationlistingDatabaseApp.swift
// Entry point of the LicensingDatabaseApp. Initializes the root view and injects the shared view model.
//

import SwiftUI

// Marks this struct as the entry point of the app.

// Main application structure conforming to the App protocol.
@main
struct LicensingDatabaseApp: App {
    // Instantiates the shared view model and makes it observable throughout the app's view hierarchy.
    @StateObject private var viewModel = RegistrationViewModel()

    // Defines the window scene and the root view.
    var body: some Scene {
        // Sets RegListContentView as the root view and provides the view model as an environment object.
        WindowGroup {
            RegListContentView()
                .environmentObject(viewModel)
        }
    }
}
