//
//  HistoricalDocsAppApp.swift
//  HistoricalDocsApp
//
//  Created by Tanay Doppalapudi on 6/19/25.
//

// HistoricalDocsAppApp.swift
// Entry point for the HistoricalDocsApp. Initializes and displays the main content view.

import SwiftUI

// Marks this struct as the entry point of the SwiftUI app.
// Main application structure conforming to the App protocol.
@main
struct HistoricalDocsAppApp: App {
    // Declares the app's user interface scene.
    var body: some Scene {
        // Sets the main content view (HistContentView) as the root view for the app.
        WindowGroup {
            HistContentView()
        }
    }
}
