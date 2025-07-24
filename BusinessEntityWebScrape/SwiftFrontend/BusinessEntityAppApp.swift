//
// BusinessEntityAppApp.swift
// Entry point for the BusinessEntityApp. Initializes and displays the main view.
//
//  BusinessEntityAppApp.swift
//  BusinessEntityApp
//
//  Created by Tanay Doppalapudi on 7/17/25.
//

import SwiftUI

// Marks this struct as the application's main entry point.
// Main application structure conforming to the App protocol.
@main
struct BusinessEntityAppApp: App {
    // Defines the main scene of the app's user interface.
    var body: some Scene {
        // Loads the BEContentView as the root view of the app.
        WindowGroup {
            BEContentView()
        }
    }
}
