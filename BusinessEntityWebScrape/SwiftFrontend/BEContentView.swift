//
// BEContentView.swift
// Displays a searchable list of business entities using SwiftUI and a view model store.
//

import SwiftUI

// Main view that presents the business entity list and handles search functionality.
struct BEContentView: View {
  // View model for loading and storing business entity data.
  @StateObject private var store = BusinessEntityStore()
  // User input for the searchable text field.
  @State private var searchText = ""

  // UI layout for the main screen, including navigation and searchable list.
  var body: some View {
    // Provides navigation bar and view hierarchy.
    NavigationView {
      // Displays a list of business entities with headline and subheadline styles.
      List(store.allEntities) { entity in
        VStack(alignment: .leading) {
          Text(entity.name).font(.headline)
          Text(entity.entityType).font(.subheadline)
        }
      }
      // Adds a built-in search bar bound to `searchText` with placeholder prompt.
      .searchable(text: $searchText, prompt: "Search by name…")
      // Triggers data reload when the search text changes.
      .onChange(of: searchText) {
        store.loadAll(filter: searchText)
      }
      // Sets the title shown in the navigation bar.
      .navigationTitle("CA Business Entities")
    }
  }
}
