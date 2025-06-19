//
//  ContactViewModel.swift
//  DAContactsApp
//
//  Created by Tanay Doppalapudi on 6/17/25.
//
import Foundation

class ContactViewModel: ObservableObject {
    @Published var contacts: [Contact] = []

    func fetchContacts() {
        guard let url = URL(string: "https://dacontactsapi.onrender.com/contacts") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([Contact].self, from: data)
                    DispatchQueue.main.async {
                        self.contacts = decoded
                        print("✅ Contacts loaded: \(decoded.count)")
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                }
            } else if let error = error {
                print("❌ Request error: \(error)")
            }
        }

        task.resume()
    }
}
