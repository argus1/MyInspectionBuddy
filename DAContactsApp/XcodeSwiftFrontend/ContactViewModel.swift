//
//  ContactViewModel.swift
//  DAContactsApp
//
//  Created by Tanay Doppalapudi on 6/17/25.
//

// ViewModel for managing and filtering Contact data in DAContactsApp.

import Foundation
import Combine

// ContactViewModel conforms to ObservableObject to allow SwiftUI views to observe changes.
class ContactViewModel: ObservableObject {
    // List of all contacts fetched from the API.
    @Published var contacts: [Contact] = []
    
    // User's search input for filtering by name.
    @Published var searchName: String = ""
    
    // User's search input for filtering by county.
    @Published var searchCounty: String = ""

    // Computed property that filters contacts based on searchName and searchCounty.
    var filteredContacts: [Contact] {
        contacts.filter { contact in
            // Match if searchName is empty or matches first or last name.
            let matchesName = searchName.isEmpty ||
                contact.firstName.localizedCaseInsensitiveContains(searchName) ||
                contact.lastName.localizedCaseInsensitiveContains(searchName)

            // Match if searchCounty is empty or matches county field.
            let matchesCounty = searchCounty.isEmpty ||
                contact.county.localizedCaseInsensitiveContains(searchCounty)

            return matchesName && matchesCounty
        }
    }

    // Fetches contact data from the remote API and decodes it into Contact objects.
    func fetchContacts() {
        // Ensure the URL is valid.
        guard let url = URL(string: "https://dacontactsapi-1.onrender.com/contacts") else {
            print("Invalid URL")
            return
        }

        // Start the data task to fetch contact data.
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    // Decode the received JSON data into an array of Contact objects.
                    let decoded = try JSONDecoder().decode([Contact].self, from: data)
                    
                    // Update the contacts property on the main thread.
                    DispatchQueue.main.async {
                        self.contacts = decoded
                        print("✅ Contacts loaded: \(decoded.count)")
                    }
                } catch {
                    // Handle JSON decoding errors.
                    print("❌ Decoding error: \(error)")
                }
            } else if let error = error {
                // Handle network or request errors.
                print("❌ Request error: \(error)")
            }
        }

        // Resume the network task.
        task.resume()
    }
}
