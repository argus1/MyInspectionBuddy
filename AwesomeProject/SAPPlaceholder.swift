struct Contact {
    let county: String
    let name: String
    let address: String
    let phone: String
    let fax: String
    let website: String
}

func fetchMockContactList() -> [Contact] {
    return [
        Contact(
            county: "Los Angeles",
            name: "John Doe",
            address: "123 Main St, Los Angeles, CA",
            phone: "(123) 456-7890",
            fax: "(123) 456-7891",
            website: "https://da.lacounty.gov"
        ),
        Contact(
            county: "San Diego",
            name: "Jane Smith",
            address: "456 Elm St, San Diego, CA",
            phone: "(987) 654-3210",
            fax: "(987) 654-3211",
            website: "https://www.sdcda.org"
        )
    ]
}
