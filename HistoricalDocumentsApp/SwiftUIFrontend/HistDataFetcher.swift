// HistDataFetcher.swift
// ViewModel responsible for fetching paginated FDA historical documents using query parameters.

import Foundation

// ObservableObject managing document results, loading state, and error messages.
class HistDataFetcher: ObservableObject {
    // List of fetched documents to be displayed.
    @Published var documents: [FDADocument] = []
    // Flag to indicate if data is currently loading.
    @Published var isLoading = false
    // Error message to be displayed if a request fails.
    @Published var errorMessage: String? = nil
    // Tracks the current page for pagination.
    @Published var currentPage = 1
    // Indicates if more pages are available.
    @Published var hasMore = true
    // Total number of results returned by the API.
    @Published var totalResults = 0

    /// Fetch documents from the backend API with optional filters for type and date range.
    /// - Parameters:
    ///   - query: Text query string for search.
    ///   - docType: Optional document type filter.
    ///   - startDate: Optional start date for filtering (YYYY-MM-DD).
    ///   - endDate: Optional end date for filtering (YYYY-MM-DD).
    ///   - page: Page number for pagination (default: 1).
    ///   - limit: Number of results per page (default: 20).
    func fetchDocuments(
        query: String,
        docType: String,
        startDate: String,
        endDate: String,
        page: Int = 1,
        limit: Int = 20
    ) {
        isLoading = true
        errorMessage = nil

        // Build the URL with query parameters.
        let base = "https://historicaldocumentsapi.onrender.com/search"
        var components = URLComponents(string: base)!
        var queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if !docType.isEmpty {
            queryItems.append(URLQueryItem(name: "title", value: docType))
        }
        if !startDate.isEmpty && !endDate.isEmpty {
            queryItems.append(URLQueryItem(name: "start_date", value: startDate))
            queryItems.append(URLQueryItem(name: "end_date", value: endDate))
        }
        components.queryItems = queryItems

        // Validate the constructed URL.
        guard let url = components.url else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }

        print("📡 Fetching URL: \(url.absoluteString)")
        print("📅 Date Range: \(startDate) to \(endDate)")

        // Perform the network request to fetch document data.
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async { self.isLoading = false }

            // Handle networking error.
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            // Ensure data is returned.
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received."
                }
                return
            }

            // Debug print of raw JSON string for inspection.
            if let jsonString = String(data: data, encoding: .utf8) {
                print("RAW JSON:\n\(jsonString)")
            }

            do {
                // Attempt to decode the API response into FDAResponse model.
                let decoder = JSONDecoder()
                let response = try decoder.decode(FDAResponse.self, from: data)

                DispatchQueue.main.async {
                    // Replace or append to document list based on page number.
                    if page == 1 {
                        self.documents = response.results
                    } else {
                        self.documents += response.results
                    }
                    self.totalResults = response.meta.total
                    self.hasMore = (self.documents.count < self.totalResults)
                    self.currentPage = page
                }

            } catch {
                // Handle decoding errors and show user-friendly message.
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }
        .resume()
    }
}
