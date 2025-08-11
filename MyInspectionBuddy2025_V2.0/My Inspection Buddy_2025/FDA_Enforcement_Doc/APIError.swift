//
//  FDAError.swift
//  My Inspection Buddy_MergeV1.0
//
//  Created by Rae Wang on 7/14/25.
//

import Foundation

// A centralized, generic error type for all API calls in the app.
enum APIError: Error, LocalizedError {
    case invalidURL
    case encodingFailed(Error) // New case added to handle request creation errors
    case requestFailed(Error)
    case decodingFailed(Error)
    case apiError(String) // A specific case for API-level errors like "NOT_FOUND"
    case noResults // A specific case for when a search is valid but returns nothing

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .encodingFailed:
            return "Failed to prepare the request."
        case .requestFailed:
            return "The network request failed. Please check your connection."
        case .decodingFailed:
            return "Failed to understand the response from the server."
        case .apiError(let message):
            // Return the actual error message from the API
            return message
        case .noResults:
            return "No results were found for the provided criteria."
        }
    }
}

//target has swift tasks not blocking downstream targets
