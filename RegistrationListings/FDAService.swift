//
//  FDAService.swift
//  Provides asynchronous API calls to the FDA device registration listing endpoint.
//

import Foundation

// MARK: - API Error Response Model
// Represents the error response structure returned by the FDA API.
struct APIErrorResponse: Decodable {
    let error: APIError

    struct APIError: Decodable {
        let code: String
        let message: String
    }
}

// MARK: - FDAService
// Provides a function to fetch paginated FDA registration data from the openFDA API.
class FDAService {
    // Base URL for the FDA device registration listing endpoint.
    private let baseURL = "https://api.fda.gov/device/registrationlisting.json"
    
    /// Fetches a page of FDA registrations using the given query, limit, and skip values.
    /// - Parameters:
    ///   - rawQuery: The search query string for the API.
    ///   - limit: Number of results to return per page (default is 25).
    ///   - skip: Number of results to skip for pagination (default is 0).
    /// - Returns: A tuple of decoded FDARegistration array and total result count.
    func fetchRegistrations(
        query rawQuery: String,
        limit: Int = 25,
        skip: Int = 0
    ) async throws -> ([FDARegistration], Int) {
        
        // Use a match-all fallback query if no search string is provided.
        // 👉 Changed registration.registration_number to registration_detail.registration_number
        let safeQuery = rawQuery.isEmpty
            ? "registration_detail.registration_number:[* TO *]"
            : rawQuery
        
        // Construct the URL with query parameters.
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "search", value: safeQuery),
            URLQueryItem(name: "limit",  value: "\(limit)"),
            URLQueryItem(name: "skip",   value: "\(skip)")
        ]
        
        // Ensure the final URL is valid.
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        print("📡 Fetching from: \(url)")
        
        // Make the asynchronous network request to fetch data from the API.
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Log the HTTP status code for debugging.
        if let httpResponse = response as? HTTPURLResponse {
            print("🔎 Status Code: \(httpResponse.statusCode)")
        }
        
        do {
            // Attempt to decode the response as an API error object first.
            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                print("⚠️ API returned error: \(apiError.error.message)")
                throw NSError(domain: "FDAService",
                              code: 404,
                              userInfo: [NSLocalizedDescriptionKey: apiError.error.message])
            }
            // Decode the response into the expected FDAResponse model.
            let decoded = try JSONDecoder().decode(FDAResponse.self, from: data)
            return (decoded.results, decoded.meta.results.total)
        } catch {
            // If decoding fails, print the raw response body for debugging.
            if let rawBody = String(data: data, encoding: .utf8) {
                print("🔻 Raw Response Body: \(rawBody)")
            }
            // Log the decoding error.
            print("❌ Decoding error: \(error)")
            throw error
        }
    }
}
