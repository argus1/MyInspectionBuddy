//
//  ContentView.swift
//  DAContactsApp
//
//  Created by Tanay Doppalapudi on 6/17/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContactViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.contacts) { contact in
                NavigationLink(destination: ContactDetailView(contact: contact)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(contact.name).font(.headline)
                        Text(contact.county).font(.subheadline).foregroundColor(.gray)
                        Text(contact.phone).font(.footnote).foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("DA Contacts")
            .onAppear {
                viewModel.fetchContacts()
            }
        }
    }
}
