import Foundation

struct FDAResponse: Decodable {
    let results: [MAUDEEvent]
    let meta: Meta
}

struct Meta: Decodable {
    let results: MetaResults
}

struct MetaResults: Decodable {
    let total: Int
    let skip: Int
    let limit: Int
}

struct MAUDEEvent: Decodable, Identifiable {
    var id = UUID()  // This stays, but must not be decoded

    let report_number: String
    let date_received: String
    let event_type: String
    let device: [Device]

    enum CodingKeys: String, CodingKey {
        case report_number
        case date_received
        case event_type
        case device
        // DO NOT include `id`
    }
}

struct Device: Decodable {
    let brand_name: String?
    let generic_name: String?
    let device_report_product_code: String?
}
