import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case encodingFailed(Error)
    case noResults
    
    var errorDescription: String? {
        switch self {
            case .invalidURL: return "The URL was invalid."
            case .requestFailed: return "The network request failed. Please check your connection and the server status."
            // FIX: The string is now correctly terminated on a single line.
            case .decodingFailed: return "Failed to understand the response from the server. The data format may have changed."
            case .encodingFailed: return "Failed to prepare the data to send to the server."
            case .noResults: return "No search criteria provided."
        }
    }
}

