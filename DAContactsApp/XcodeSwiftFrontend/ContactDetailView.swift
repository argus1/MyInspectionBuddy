//
//  ContactDetailView.swift
//  DAContactsApp
//
//  Created by Tanay Doppalapudi on 6/17/25.
//
import SwiftUI

struct ContactDetailView: View {
    let contact: Contact

    var body: some View {
        Form {
            Section(header: Text("Name")) {
                Text(contact.name)
            }

            Section(header: Text("County")) {
                Text(contact.county)
            }

            Section(header: Text("Phone")) {
                Link(contact.phone, destination: URL(string: "tel:\(contact.phone.filter { $0.isNumber })")!)
            }

            Section(header: Text("Address")) {
                Text(contact.address)
            }

            Section(header: Text("Fax")) {
                Text(contact.fax)
            }

            Section(header: Text("Website")) {
                Link("Visit Website", destination: URL(string: contact.website)!)
            }
        }
        .navigationTitle(contact.name)
    }
}
