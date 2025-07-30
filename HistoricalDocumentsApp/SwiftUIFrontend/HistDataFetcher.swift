// HistDataFetcher.swift
// Handles fetching FDA historical documents from the API, decoding JSON, and managing pagination and loading state.

// Foundation provides URLSession, data tasks, and basic data types.
import Foundation

// ObservableObject managing document fetch operations and publishing state updates to the UI.
class HistDataFetcher: ObservableObject {
    // The list of fetched documents to display in the UI.
    @Published var documents: [FDADocument] = []
    // Tracks whether a fetch request is currently in progress.
    @Published var isLoading = false
    // Holds any error message to display if fetching or decoding fails.
    @Published var errorMessage: String? = nil
    // The current page number for paginated API requests.
    @Published var currentPage = 1
    // Indicates if more pages are available based on totalResults and documents count.
    @Published var hasMore = true
    // The total number of results reported by the API.
    @Published var totalResults = 0

    // Fetch documents from the API using given filters and pagination parameters.
    func fetchDocuments(query: String, docType: String, startDate: String, endDate: String, page: Int = 1, limit: Int = 20) {
        // Begin fetch: reset error and set loading state.
        isLoading = true
        errorMessage = nil

        // Construct the base URL and append query parameters.
        let base = "https://historicaldocumentsapi.onrender.com/search"
        var components = URLComponents(string: base)!

        // Required query items: search text, page number, and page size.
        var queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]

        // Append document type filter if provided.
        if !docType.isEmpty {
            queryItems.append(URLQueryItem(name: "title", value: docType))
        }
        // Append date range filters if both start and end dates are provided.
        if !startDate.isEmpty && !endDate.isEmpty {
            queryItems.append(URLQueryItem(name: "start_date", value: startDate))
            queryItems.append(URLQueryItem(name: "end_date", value: endDate))
        }

        components.queryItems = queryItems

        // Validate the URL constructed from components.
        guard let url = components.url else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }

        // Perform the network request asynchronously.
        URLSession.shared.dataTask(with: url) { data, response, error in
            // On response, clear loading indicator on the main thread.
            DispatchQueue.main.async {
                self.isLoading = false
            }

            // Handle network errors by updating the errorMessage.
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            // Ensure data was received; otherwise, set an error.
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received."
                }
                return
            }

            // Debug: log the raw JSON response for troubleshooting.
            if let jsonString = String(data: data, encoding: .utf8) {
                print("RAW JSON:\n\(jsonString)")
            }

            // Attempt to decode the JSON into our response and update state.
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(FDAResponse.self, from: data)
                print("✅ Decoded \(response.results.count) results")

                DispatchQueue.main.async {
                    if page == 1 {
                        self.documents = response.results
                    } else {
                        self.documents += response.results
                    }
                    self.totalResults = response.meta.total
                    self.hasMore = (self.documents.count < self.totalResults)
                    self.currentPage = page
                }
            }
            // Handle data corrupted decoding errors with descriptive messages.
            catch let DecodingError.dataCorrupted(context) {
                // Handle dataCorrupted decoding errors.
                print("Data corrupted:", context.debugDescription)
                print("codingPath:", context.codingPath)
                DispatchQueue.main.async {
                    self.errorMessage = "Data corrupted: \(context.debugDescription)"
                }
            }
            // Handle keyNotFound decoding errors.
            catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key.stringValue)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
                DispatchQueue.main.async {
                    self.errorMessage = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
                }
            }
            // Handle typeMismatch decoding errors.
            catch let DecodingError.typeMismatch(type, context) {
                print("Type mismatch for type \(type):", context.debugDescription)
                print("codingPath:", context.codingPath)
                DispatchQueue.main.async {
                    self.errorMessage = "Type mismatch for type \(type): \(context.debugDescription)"
                }
            }
            // Handle valueNotFound decoding errors.
            catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
                DispatchQueue.main.async {
                    self.errorMessage = "Value '\(value)' not found: \(context.debugDescription)"
                }
            }
            // Handle any other unexpected errors.
            catch {
                print("Unexpected decoding error:", error)
                DispatchQueue.main.async {
                    self.errorMessage = "Unexpected decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
