//
//  FDA510kResult.swift
//  510k
//
//  Created by Nicole Tang on 6/23/25.
//


import Foundation

struct FDA510kResult: Identifiable, Codable {
    let id = UUID()
    let applicant: String?
    let deviceName: String?
    let decisionDate: String?
    let kNumber: String?

    enum CodingKeys: String, CodingKey {
        case applicant
        case deviceName = "device_name"
        case decisionDate = "decision_date"
        case kNumber = "k_number"
    }
}
