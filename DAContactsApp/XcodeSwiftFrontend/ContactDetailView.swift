// ContactDetailView.swift
// DAContactsApp
//
// Created by Tanay Doppalapudi on 6/17/25.
//

// This view displays the detailed information for a selected contact using a form layout.

import SwiftUI

// ContactDetailView shows details of a single Contact in a structured format.
struct ContactDetailView: View {
    // The Contact object whose details will be displayed.
    let contact: Contact

    // The main view layout, using a Form to display sections of contact information.
    var body: some View {
        Form {
            // Section showing the contact's name.
            Section(header: Text("Name")) {
                Text(contact.name)
            }

            // Section showing the contact's county.
            Section(header: Text("County")) {
                Text(contact.county)
            }

            // Section with a clickable phone number link.
            Section(header: Text("Phone")) {
                Link(contact.phone,
                     destination: URL(string: "tel:\(contact.phone.filter { $0.isNumber })")!)
            }

            // Section showing the contact's physical address.
            Section(header: Text("Address")) {
                Text(contact.address)
            }

            // Section showing the contact's fax number.
            Section(header: Text("Fax")) {
                Text(contact.fax)
            }

            // Section with a clickable website link.
            Section(header: Text("Website")) {
                Link("Visit Website", destination: URL(string: contact.website)!)
            }
        }
        // Sets the navigation bar title to the contact's name.
        .navigationTitle(contact.name)
    }
}
