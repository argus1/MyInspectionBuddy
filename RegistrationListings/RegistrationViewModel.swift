//
// RegistrationViewModel.swift
// View model for managing FDA registration search state and API interactions in LicensingDatabaseApp.
//

import Foundation

// Ensures all published properties are updated on the main thread (safe for UI binding).
@MainActor
class RegistrationViewModel: ObservableObject {
    
    // MARK: – Published state
    // Observable state variables used to drive UI updates.
    @Published var registrations: [FDARegistration] = [] // List of currently loaded registration results.
    @Published var isLoading       = false               // Flag to show loading spinner.
    @Published var error: String?  = nil                 // Holds an error message to display.
    @Published var didTriggerSearch = false              // Flag indicating whether a search was initiated.
    @Published var totalCount      = 0                   // Total number of results reported by the API.
    
    // MARK: – Private
    // Internal state and service dependencies for pagination and search.
    private let service      = FDAService() // Instance of the service that performs API requests.
    private var currentQuery = ""           // Tracks the current search query string.
    private var currentSkip  = 0            // Tracks the number of items to skip for pagination.
    private let limit        = 20           // Fixed number of results per page.
    private var isFetchingMore = false      // Flag to prevent overlapping loadMore requests.
    
    // MARK: – Public API
    /// Initiates a new search or match-all request using the FDA API.
    func search(_ query: String) async {
        didTriggerSearch = true // Set flag to indicate search began.
        // Default to match-all on the correct JSON field
        currentQuery = query.isEmpty
            ? "registration_detail.registration_number:[* TO *]"
            : query      // Build query string; fallback to match-all if empty.

        currentSkip = 0         // Reset pagination.
        isLoading = true        // Show loading spinner.
        error = nil             // Clear any previous error.

        // Debug: print the outgoing query parameters
        print("Searching with query: \(currentQuery), skip: \(currentSkip), limit: \(limit)")

        do {
            let (results, total) = try await service.fetchRegistrations(
                query: currentQuery,
                limit: limit,
                skip: currentSkip
            )
            totalCount = total
            let sortedResults = sortUnknownLast(results)
            registrations = sortedResults

            // Handle empty-but-no-error responses
            if results.isEmpty {
                self.error = "No results found for your search."
            }
        } catch {
            let nsError = error as NSError
            if nsError.localizedDescription == "No matches found!" {
                // No matches is not a crash: clear out and show message
                self.registrations = []
                self.totalCount = 0
                if didTriggerSearch {
                    self.error = "No results found for your search."
                }
            } else {
                self.error = nsError.localizedDescription
            }
        }

        isLoading = false
    }
    
    /// Triggers loadMore() if the user scrolls near the end of the list.
    func loadMoreIfNeeded(currentItem: FDARegistration?) async {
        guard let currentItem = currentItem else { return }
        let thresholdIndex = registrations.index(registrations.endIndex, offsetBy: -5) // Defines how far from the end to trigger loading more.
        guard registrations.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex else { return }
        
        await loadMore()
    }
    
    // MARK: – Private helpers
    /// Fetches and appends the next page of results, if not already fetching.
    private func loadMore() async {
        guard !isFetchingMore,
              registrations.count < totalCount      // Prevent duplicate loads and over-fetching.
        else { return }
        
        isFetchingMore = true
        currentSkip += limit   // Update skip value for pagination.
        
        do {
            let (moreResults, _) = try await service.fetchRegistrations(
                query: currentQuery,
                limit: limit,
                skip: currentSkip
            )
            registrations.append(contentsOf: moreResults)
            registrations = sortUnknownLast(registrations)
        } catch {
            print("Failed to load more: \(error)")
        }
        
        isFetchingMore = false
    }
    
    /// Sorts results alphabetically, placing missing proprietary names at the bottom.
    private func sortUnknownLast(_ list: [FDARegistration]) -> [FDARegistration] {
        list.sorted {
            let a = $0.proprietaryName?.first ?? "zzz"
            let b = $1.proprietaryName?.first ?? "zzz"
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }
    }
    
    /// Resets view model state to prepare for a new session or clear the UI.
    func reset() {
        registrations = []
        totalCount = 0
        error = nil
        didTriggerSearch = false
        currentQuery = ""
        currentSkip = 0
    }
}
