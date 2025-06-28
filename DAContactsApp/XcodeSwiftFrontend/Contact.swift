//
//  Contact.swift
//  DAContactsApp
//
//  Created by Tanay Doppalapudi on 6/17/25.
//
import Foundation

struct Contact: Identifiable, Codable {
    let id = UUID()
    let county: String
    let name: String
    let address: String
    let phone: String
    let fax: String
    let website: String

    enum CodingKeys: String, CodingKey {
        case county = "County"
        case name = "Name"
        case address = "Address"
        case phone = "Phone"
        case fax = "Fax"
        case website = "Website"
    }
}
