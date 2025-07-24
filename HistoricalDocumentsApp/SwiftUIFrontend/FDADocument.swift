// FDADocument.swift
// Data models and extensions for decoding and presenting FDA document records.
import Foundation

// Top-level API response containing a list of FDA documents and pagination metadata.
struct FDAResponse: Decodable {
    let results: [FDADocument]
    let meta: Meta
}

// Pagination metadata returned with the API response.
struct Meta: Decodable {
    let total: Int
    let page: Int
    let limit: Int
}

// Model representing a single FDA document with optional metadata and body text.
struct FDADocument: Codable, Identifiable {
    let id: Int
    let title: String?
    let docType: String?
    let year: Int?
    let text: String?
    let effectiveDate: String?

    // Computed property to return a user-friendly string for common document type codes.
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

    // Maps Swift property names to JSON keys from the API.
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case docType = "doc_type"
        case year
        case text
        case effectiveDate = "effective_date"
    }
}

// MARK: - FDADocument Extensions
// Adds computed properties for display formatting and text parsing.

extension FDADocument {
    // Returns a descriptive label based on document type codes (e.g., "pr" -> "Press Release").
    var displayType: String {
        switch docType?.lowercased() {
        case "pr":
            return "Press Release"
        case "pha":
            return "Public Health Alert"
        case "cn":
            return "Compliance Notice"
        case "sw":
            return "Safety Warning"
        case "talk":
            return "Talk"
        default:
            return docType?.capitalized ?? "Unknown"
        }
    }

    // Attempts to extract the issuing department from the first non-empty line of the text body.
    var department: String {
        guard let text = text else { return "Unknown" }
        let lines = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return lines.first ?? "Unknown"
    }

    // Cleans and filters the body text for improved readability by removing short or empty lines.
    var cleanBody: String {
        guard let raw = text else { return "" }
        let lines = raw.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let filtered = lines.filter { line in
            let letterCount = line.unicodeScalars.filter { CharacterSet.letters.contains($0) }.count
            return letterCount >= 4
        }
        return filtered.joined(separator: "\n\n")
    }
}
