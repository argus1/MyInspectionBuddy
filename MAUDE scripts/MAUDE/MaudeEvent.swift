import Foundation

struct MaudeEvent: Codable, Identifiable, Hashable {
    var id: String { mdrReportKey }
    
    let mdrReportKey: String
    let reportNumber: String?
    let device: [MaudeDevice]
    let dateReceived: String
    let eventType: String?

    enum CodingKeys: String, CodingKey {
        case mdrReportKey = "mdr_report_key"
        case reportNumber = "report_number"
        case device
        case dateReceived = "date_received"
        case eventType = "event_type"
    }
}

struct MaudeDevice: Codable, Hashable {
    let genericName: String
    let brandName: String?
    let modelNumber: String?
    let deviceReportProductCode: String?
    let exemptionNumber: String?

    enum CodingKeys: String, CodingKey {
        case genericName = "generic_name"
        case brandName = "brand_name"
        case modelNumber = "model_number"
        case deviceReportProductCode = "device_report_product_code"
        case exemptionNumber = "exemption_number"
    }
}

struct MaudeAPIResponse: Codable {
    let results: [MaudeEvent]
}

