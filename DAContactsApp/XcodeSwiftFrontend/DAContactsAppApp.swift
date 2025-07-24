//
//  DAContactsAppApp.swift
//  DAContactsApp
//
//  Created by Tanay Doppalapudi on 6/17/25.
//

// Entry point of the DAContactsApp; sets up the root view and environment objects.

import SwiftUI

// Marks the app's entry point.
@main
// The main application structure conforming to the App protocol.
struct DAContactsAppApp: App {
    // StateObject to manage the contact view model across the app.
    @StateObject private var viewModel = ContactViewModel()

    // The scene graph defining the main window of the app.
    var body: some Scene {
        WindowGroup {
            DAContentView() // DAContentView is the root view; injecting viewModel into the environment.
                .environmentObject(viewModel)
        }
    }
}
