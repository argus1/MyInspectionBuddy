import SwiftUI

struct ContentView: View {
    let groupedContacts = Dictionary(grouping: fetchMockContactList(), by: { $0.county })

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedContacts.keys.sorted(), id: \.self) { county in
                    Section(
                        header:
                            Text(county.uppercased())
                            .font(.title3.bold())
                            .foregroundColor(color(for: county))
                            .textCase(nil)
                    ) {
                        ForEach(groupedContacts[county]!, id: \.name) { contact in
                            ContactRow(contact: contact)
                                .padding(.bottom, 8)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear) // ← removes extra background
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("SAP Contacts")
        }
    }

    func color(for county: String) -> Color {
        switch county.lowercased() {
        case "los angeles": return .red
        case "orange": return .orange
        case "san diego": return .blue
        default: return .gray
        }
    }
}
