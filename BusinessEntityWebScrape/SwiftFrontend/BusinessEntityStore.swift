//
// BusinessEntityStore.swift
// View model responsible for loading business entity data from a local SQLite database.

import Foundation
import SQLite

// ObservableObject that loads and filters business entity data from a pre-bundled SQLite database.
class BusinessEntityStore: ObservableObject {
  // SQLite database connection.
  private var db: Connection!
  // Column reference for id in the entities table.
  private let idCol = Expression<Int64>("id")
  // Column reference for name in the entities table.
  private let nameCol = Expression<String>("name")
  // Column reference for entity_type in the entities table.
  private let typeCol = Expression<String>("entity_type")
  // Column reference for registration_number in the entities table.
  private let regCol = Expression<String>("registration_number")
  // Column reference for status in the entities table.
  private let statusCol = Expression<String>("status")
  // Column reference for info_url in the entities table.
  private let urlCol = Expression<String>("info_url")
  private let table = Table("entities")

  // Array of all (or filtered) business entities loaded from the database.
  @Published var allEntities: [BusinessEntity] = []

  // Initializes the store by opening the database and loading all entities.
  init() {
    openDatabase()
    loadAll()
  }

  // Copies the bundled read-only database to the Documents directory (if not already copied), then opens a connection to it.
  private func openDatabase() {
    // Get path to Documents directory where writable files are allowed.
    let fm = FileManager.default
    let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
    let destURL = docs.appendingPathComponent("business_entities.db")
    // Copy the bundled database file to the destination path if it doesn't exist there yet.
    if !fm.fileExists(atPath: destURL.path) {
      let bundleURL = Bundle.main.url(forResource: "business_entities", withExtension: "db")!
      try! fm.copyItem(at: bundleURL, to: destURL)
    }
    // Open a read-only SQLite connection to the database.
    db = try! Connection(destURL.path, readonly: true)
  }

  // Loads all business entities from the database, with optional name filtering.
  func loadAll(filter: String = "") {
    var query = table.order(nameCol.asc)
    // Apply case-insensitive filtering on the name column if a filter string is provided.
    if !filter.isEmpty {
      query = query.filter(nameCol.lowercaseString.like("%\(filter.lowercased())%"))
    }
    allEntities = try! db.prepare(query).map { row in
      // Map each row in the result to a BusinessEntity model instance.
      BusinessEntity(
        id: row[idCol],
        name: row[nameCol],
        entityType: row[typeCol],
        registrationNumber: row[regCol],
        status: row[statusCol],
        infoURL: URL(string: row[urlCol])!
      )
    }
  }
}
