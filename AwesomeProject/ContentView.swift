import SwiftUI

struct ContentView: View {
    let contacts = fetchMockContactList()

    var body: some View {
        NavigationView {
            List(contacts, id: \.name) { contact in
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.headline)
                    Text(contact.county)
                        .font(.subheadline)
                    Text(contact.website)
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("SAP Contacts")
        }
    }
}
