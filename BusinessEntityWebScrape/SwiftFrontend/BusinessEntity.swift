// BusinessEntity.swift
// Defines the BusinessEntity model used to represent each business entity in the app.

//
//  BusinessEntity.swift
//  BusinessEntityApp
//
//  Created by Tanay Doppalapudi on 7/17/25.
//

import Foundation

// Model representing a business entity, conforming to Identifiable for use in SwiftUI lists.
struct BusinessEntity: Identifiable {
  // Unique identifier for the business entity.
  let id: Int64
  // Name of the business entity.
  let name: String
  // Type of entity (e.g. LLC, Corporation, etc.).
  let entityType: String
  // Official registration number assigned by the state.
  let registrationNumber: String
  // Current operational status of the business.
  let status: String
  // URL linking to more information about the business.
  let infoURL: URL
}
