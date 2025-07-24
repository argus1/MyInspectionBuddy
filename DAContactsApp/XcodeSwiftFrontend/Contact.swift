// This file defines the Contact model used to represent each contact in the DAContactsApp.

// Contact.swift
// DAContactsApp
//
// Created by Tanay Doppalapudi on 6/17/25.
//

import Foundation

// The Contact struct conforms to Identifiable and Codable protocols for use in SwiftUI lists and JSON encoding/decoding.
struct Contact: Identifiable, Codable {
    // Unique identifier for each contact (used for SwiftUI list differentiation).
    let id = UUID()
    
    // County where the contact is located.
    let county: String
    // Full name of the contact.
    let name: String
    // Street address of the contact.
    let address: String
    // Phone number for the contact.
    let phone: String
    // Fax number for the contact.
    let fax: String
    // Website URL for the contact.
    let website: String

    // Computed properties to help with filtering
    // Extracts and returns the first name from the full name.
    var firstName: String {
        return name.components(separatedBy: " ").first ?? ""
    }

    // Extracts and returns the last name from the full name.
    var lastName: String {
        return name.components(separatedBy: " ").last ?? ""
    }

    // Maps JSON keys to struct property names for Codable conformance.
    enum CodingKeys: String, CodingKey {
        case county = "County"
        case name = "Name"
        case address = "Address"
        case phone = "Phone"
        case fax = "Fax"
        case website = "Website"
    }
}
