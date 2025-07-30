// FDADocument.swift
// Models for decoding FDA API responses and representing document metadata.
// Also includes formatting helpers and drag/copy support.

// Core Foundation: basic types and data utilities.
import Foundation
// UniformTypeIdentifiers: defines UTType for drag-and-drop data formats.
import UniformTypeIdentifiers
// SwiftUI: UI components and Transferable protocol for drag support.
import SwiftUI

// Top-level API response, containing an array of documents and pagination metadata.
struct FDAResponse: Decodable {
    let results: [FDADocument]
    let meta: Meta
}

// Metadata about the API response: total items, current page, and items per page.
struct Meta: Decodable {
    let total: Int
    let page: Int
    let limit: Int
}

// Represents a single FDA document with its properties decoded from JSON.
struct FDADocument: Codable, Identifiable {
    // Unique identifier for the document.
    let id: Int
    // Optional document title.
    let title: String?
    // Raw document type code (e.g., "pr" or "talk").
    let docType: String?
    // Year the document was released.
    let year: Int?
    // Full text content of the document.
    let text: String?
    // Official effective date of the document.
    let effectiveDate: String?

    // Converts raw docType codes into a human-readable label.
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

    // Maps JSON keys to Swift property names during decoding.
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case docType = "doc_type"
        case year
        case text
        case effectiveDate = "effective_date"
    }

    // Builds a formatted string containing key document details and a text excerpt.
    func formattedInfo() -> String {
        // Start with an empty string accumulator.
        var info = ""
        // Append the title if available.
        if let title = title {
            info += "Title: \(title)\n"
        }
        // Always include the document type.
        info += "Type: \(displayDocType)\n"
        // Append the year if available.
        if let year = year {
            info += "Year: \(year)\n"
        }
        // Append the effective date if available.
        if let effectiveDate = effectiveDate {
            info += "Effective Date: \(effectiveDate)\n"
        }
        // Append a brief excerpt (first 300 characters) of the document text.
        if let text = text {
            info += "\nExcerpt:\n\(text.prefix(300))..."
        }
        return info
    }
}

// Enables drag-and-drop and copy support by exporting formattedInfo as plain text.
extension FDADocument: Transferable {
    // Provide a DataRepresentation with UTF-8 plain text of the document info.
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .utf8PlainText) { (document: FDADocument) in
            // Debug: log the text being dragged.
            print("Dragging text: \(document.formattedInfo())")
            // Return the encoded data for the drag payload.
            return document.formattedInfo().data(using: .utf8)!
        }
    }
}
