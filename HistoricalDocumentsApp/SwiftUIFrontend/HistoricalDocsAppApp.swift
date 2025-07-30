// HistoricalDocsAppApp.swift
// Entry point of the HistoricalDocsApp: sets up the main SwiftUI app structure.
//
//  HistoricalDocsAppApp.swift
//  HistoricalDocsApp
//
//  Created by Tanay Doppalapudi on 6/19/25.
//

// SwiftUI framework: provides UI components and app lifecycle management.
import SwiftUI

// Marks the main entry point of the app.
@main
// Defines the app's structure and the scenes it presents.
struct HistoricalDocsAppApp: App {
    // Defines the content and behavior of the app's main scene.
    var body: some Scene {
        // The primary window group that hosts the ContentView.
        WindowGroup {
            ContentView()
        }
    }
}
