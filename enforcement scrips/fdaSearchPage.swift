
import Foundation
import Combine

@MainActor
class FDASearchViewModel: ObservableObject {
    
    @Published var recallNumber: String = ""
    @Published var recallingFirm: String = ""
    @Published var fromDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    @Published var toDate: Date = Date()
    
    @Published var selectedClassification: String = "Any"
    let classificationOptions = ["Any", "Class I", "Class II", "Class III"]
    
    @Published var searchResults: [Recall] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func executeSearch() {
        print("Starting search...")
        isLoading = true
        errorMessage = nil
        searchResults = []
        
        FDARecallService.shared.searchRecalls(
            firm: recallingFirm,
            number: recallNumber,
            classification: selectedClassification,
            fromDate: fromDate,
            toDate: toDate
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            self?.isLoading = false
            switch completion {
            case .finished:
                print("Search finished successfully.")
            case .failure(let error):
                print("Search failed with error: \(error.localizedDescription)")
                self?.errorMessage = "Search failed: \(error.localizedDescription)"
            }
        }, receiveValue: { [weak self] recalls in
            print("Received \(recalls.count) recalls.")
            self?.searchResults = recalls
        })
        .store(in: &cancellables)
    }
}

