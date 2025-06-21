import Foundation

struct FDAResponse: Decodable {
    let results: [FDADocument]
    let meta: Meta
}

struct Meta: Decodable {
    let total: Int
    let page: Int
    let limit: Int
}

struct FDADocument: Codable, Identifiable {
    let id: Int
    let title: String?
    let docType: String?
    let year: Int?
    let text: String?
    let effectiveDate: String?

    var displayDocType: String {
        switch docType {
        case "pr":
            return "Press Release"
        case "talk":
            return "Talk"
        default:
            return docType ?? "Unknown"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case docType = "doc_type"
        case year
        case text
        case effectiveDate = "effective_date"
    }
}
