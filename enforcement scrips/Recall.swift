import Foundation

// We use the recall_number as the unique ID
struct Recall: Codable, Identifiable, Hashable {
    
    var id: String { recall_number }
    
    let recall_number: String
    let recalling_firm: String
    let reason_for_recall: String
    let status: String
    let classification: String
    let code_info: String
    let product_description: String
}

struct RecallAPIResponse: Codable {
    let results: [Recall]
}
