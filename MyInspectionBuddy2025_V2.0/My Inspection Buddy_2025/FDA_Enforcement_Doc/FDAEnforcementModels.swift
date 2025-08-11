//import Foundation
//
//struct FDAEnforcementResponse: Codable {
//    let results: [FDAEnforcementRecord]?
//    let error: FDAErrorPayload?
//}
//
//struct FDAEnforcementRecord: Codable, Identifiable, Hashable {
//    var id: String { recallNumber }
//    
//    let recallNumber: String
//    let recallingFirm: String
//    let reasonForRecall: String
//    let status: String
//    let classification: String
//    let codeInfo: String
//    let productDescription: String
//
//    enum CodingKeys: String, CodingKey {
//        case recallNumber = "recall_number"
//        case recallingFirm = "recalling_firm"
//        case reasonForRecall = "reason_for_recall"
//        case status
//        case classification
//        case codeInfo = "code_info"
//        case productDescription = "product_description"
//    }
//}
//
//struct FDAErrorPayload: Codable {
//    let code: String
//    let message: String
//}

import Foundation

// MARK: - API Response Structures

/// Represents the top-level response from the FDA Enforcement API.
struct FDAEnforcementResponse: Codable {
    /// An array of recall records, which is nil if the API returns an error.
    let results: [FDAEnforcementRecord]?
    
    /// A potential error payload from the API. This is present if the request fails at the API level.
    let error: FDAErrorPayload?
}

/// Represents a single device enforcement record from the FDA API.
struct FDAEnforcementRecord: Codable, Identifiable, Hashable {
    
    // MARK: - Properties
    
    /// The unique recall number, used as the stable identifier for the record.
    var id: String { recallNumber }
    
    let recallNumber: String
    let recallingFirm: String
    let reasonForRecall: String
    let status: String
    let classification: RecallClassification // Changed from String to a type-safe enum
    let codeInfo: String
    let productDescription: String
        
    enum CodingKeys: String, CodingKey {
        case recallNumber = "recall_number"
        case recallingFirm = "recalling_firm"
        case reasonForRecall = "reason_for_recall"
        case status
        case classification
        case codeInfo = "code_info"
        case productDescription = "product_description"
    }
}

// MARK: - Supporting Types

/// Represents the classification level of a recall (e.g., Class I, II, or III).
/// Conforming to String and Codable allows for easy decoding from the API response.
enum RecallClassification: String, Codable, Hashable, CaseIterable {
    case classI = "Class I"
    case classII = "Class II"
    case classIII = "Class III"
}

/// Represents the error structure returned by the FDA API when a request is invalid.
struct FDAErrorPayload: Codable {
    let code: String
    let message: String
}

