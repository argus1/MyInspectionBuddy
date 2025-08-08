import Foundation

struct Contact: Identifiable {
    let id = UUID()
    let county: String
    let name: String
    let address: String
    let phone: String
    let email: String
    let website: String
}


func fetchMockContactList() -> [Contact] {
    return [
        Contact(county: "Los Angeles", name: "John Doe", address: "123 Main St", phone: "1234567890", email: "john.doe@la.gov", website: "https://da.lacounty.gov"),
        Contact(county: "Los Angeles", name: "Lisa Ray", address: "789 Pine St", phone: "9876543210", email: "lisa.ray@la.gov", website: "https://la.agency.org"),
        Contact(county: "San Diego", name: "Jane Smith", address: "456 Elm St", phone: "9876543211", email: "jane.smith@sandiego.gov", website: "https://www.sdcda.org"),
        Contact(county: "San Diego", name: "Alan Chen", address: "322 Ocean Blvd", phone: "4567891230", email: "alan.chen@sdcda.org", website: "https://sdcda.org"),
        Contact(county: "Orange", name: "Grace Liu", address: "101 Valley Rd", phone: "5621234567", email: "grace.liu@ocgov.com", website: "https://ocgov.com"),
        Contact(county: "Orange", name: "Ben Torres", address: "89 Ridge Dr", phone: "7149998888", email: "ben.torres@ocgov.com", website: "https://ocjustice.org")
    ]
}
