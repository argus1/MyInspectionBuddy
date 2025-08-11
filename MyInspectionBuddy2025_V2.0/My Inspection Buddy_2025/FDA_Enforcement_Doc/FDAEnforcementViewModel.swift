import Foundation
import Combine
import SwiftUI // Add SwiftUI for @MainActor if not already there

@MainActor
class FDASearchViewModel: ObservableObject {
    
    // --- EXISTING PROPERTIES ---
    @Published var recallNumber: String = ""
    @Published var recallingFirm: String = ""
    @Published var fromDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    @Published var toDate: Date = Date()
    @Published var selectedClassification: String = "Any"
    let classificationOptions = ["Any", "Class I", "Class II", "Class III"]
    @Published var searchResults: [FDAEnforcementRecord] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // --- NEW PROPERTIES for History ---
    @Published var searchHistory: [HistoryItem] = []
    @Published var isHistorySidebarVisible: Bool = false
    private let searchType = "FDA_Enforcement" // Unique key for this search type

    private var cancellables = Set<AnyCancellable>()
    
    // --- NEW ---
    init() {
        loadHistory()
    }
    
    // --- NEW FUNCTIONS for History ---
    func loadHistory() {
        self.searchHistory = SearchHistoryService.getHistory(for: searchType)
    }
    
    func clearHistory() {
        SearchHistoryService.clearHistory(for: searchType)
        self.searchHistory = []
    }
    
    func selectHistoryItem(_ item: HistoryItem) {
        self.recallingFirm = item.searchTerm
        self.fromDate = item.fromDate
        self.toDate = item.toDate
        self.selectedClassification = item.docType ?? "Any"
        self.isHistorySidebarVisible = false // Hide sidebar after selection
        executeSearch() // Optionally, run the search immediately
    }
    
    func toggleHistorySidebar() {
        self.isHistorySidebarVisible.toggle()
    }
    
    // Helper to create a descriptive term for history
    private func createSearchTerm() -> String {
        return recallingFirm.isEmpty ? "Any Firm" : recallingFirm
    }

    func executeSearch() {
        isLoading = true
        errorMessage = nil
        searchResults = []
        
        // --- NEW: Save the search to history before executing ---
        let historyItem = HistoryItem(
            searchTerm: createSearchTerm(),
            fromDate: fromDate,
            toDate: toDate,
            docType: selectedClassification
        )
        SearchHistoryService.saveSearch(for: searchType, item: historyItem)
        loadHistory() // Refresh the history list

        FDARecallService.shared.searchRecalls(
            firm: recallingFirm,
            number: recallNumber,
            classification: selectedClassification,
            fromDate: fromDate,
            toDate: toDate
        )
        // ... rest of the sink block remains the same ...
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            // ... as before ...
        }, receiveValue: { [weak self] recalls in
            // ... as before ...
        })
        .store(in: &cancellables)
    }
}



//import Foundation
//import Combine
//
//@MainActor
//class FDASearchViewModel: ObservableObject {
//    
//    @Published var recallNumber: String = ""
//    @Published var recallingFirm: String = ""
//    @Published var fromDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
//    @Published var toDate: Date = Date()
//    
//    @Published var selectedClassification: String = "Any"
//    let classificationOptions = ["Any", "Class I", "Class II", "Class III"]
//    
//    @Published var searchResults: [FDAEnforcementRecord] = []
//    
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    func executeSearch() {
//        isLoading = true
//        errorMessage = nil
//        searchResults = []
//        
//        FDARecallService.shared.searchRecalls(
//            firm: recallingFirm,
//            number: recallNumber,
//            classification: selectedClassification,
//            fromDate: fromDate,
//            toDate: toDate
//        )
//        .receive(on: DispatchQueue.main)
//        .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<APIError>) in
//            self?.isLoading = false
//            switch completion {
//            case .finished:
//                break // Success is handled in receiveValue
//            case .failure(let error):
//                self?.errorMessage = error.localizedDescription
//            }
//        }, receiveValue: { [weak self] (recalls: [FDAEnforcementRecord]) in
//            self?.searchResults = recalls
//            if recalls.isEmpty {
//                self?.errorMessage = "No results found matching your criteria."
//            }
//        })
//        .store(in: &cancellables)
//    }
//}

