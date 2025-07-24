//
// PrivacyPolicyDisplayApp.swift
// Entry point for the PrivacyPolicyDisplay app, launching the main content view.
//

import SwiftUI

// Marks the struct as the application's entry point.
// Main application definition conforming to the App protocol.
@main
struct PrivacyPolicyDisplayApp: App {
    // Declares the scene that defines the app's UI hierarchy.
    var body: some Scene {
        // Creates a new window containing the PPContentView as the root view.
        WindowGroup {
            PPContentView()
        }
    }
}
