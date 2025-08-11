//
//  HistoryItem.swift
//  My Inspection Buddy_MergeV1.0
//
//  Created by Rae Wang on 8/10/25.
//
import Foundation

struct HistoryItem: Codable, Identifiable, Hashable {
    let id: UUID
    let searchTerm: String
    let fromDate: Date
    let toDate: Date
    let docType: String? 
    let createdAt: Date

    init(id: UUID = UUID(), searchTerm: String, fromDate: Date, toDate: Date, docType: String?) {
        self.id = id
        self.searchTerm = searchTerm
        self.fromDate = fromDate
        self.toDate = toDate
        self.docType = docType
        self.createdAt = Date()
    }
}
