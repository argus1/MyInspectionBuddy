// This file defines the Contact model used to represent each contact in the DAContactsApp.

// Contact.swift
// DAContactsApp
//
// Created by Tanay Doppalapudi on 6/17/25.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

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

    // Flag indicating if the contact was manually added via custom input
    var isCustom: Bool = false

    // Explicit initializer for quick contact creation with minimal data
    init(name: String, county: String, phone: String, isCustom: Bool = false) {
        self.county = county
        self.name = name
        self.address = ""
        self.phone = phone
        self.fax = ""
        self.website = ""
        self.isCustom = isCustom
    }

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

// MARK: - Transferable Conformance
extension Contact: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        // Export as raw vCard data so Contacts.app can import directly
        DataRepresentation(exportedContentType: .vCard) { (contact: Contact) in
            let vcardString = """
            BEGIN:VCARD
            VERSION:3.0
            N:\(contact.lastName);\(contact.firstName);;;
            FN:\(contact.name)
            TEL;TYPE=WORK,VOICE:\(contact.phone)
            NOTE:County: \(contact.county)
            END:VCARD
            """
            return vcardString.data(using: .utf8) ?? Data()
        }

        // Fallback to plain text for apps that don't support vCard
        ProxyRepresentation<Contact, String>(exporting: \.transferSummary)
    }
    // Computed property to generate the text we will share when dragged or copied
    var transferSummary: String {
        return "\(name)\nPhone: \(phone)\nCounty: \(county)"
    }
}
