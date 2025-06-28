import Foundation
import Combine

@MainActor
class MaudeSearchViewModel: ObservableObject {
    
    @Published var deviceName: String = ""
    @Published var fromDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    @Published var toDate: Date = Date()
    
    @Published var searchResults: [MaudeEvent] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private var isSearchDisabled: Bool {
        deviceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func executeSearch() {
        print("--- Execute Search Tapped! ---") //test
        
        guard !isSearchDisabled else {
            errorMessage = "Device Name is a required field."
            return
        }
        
        isLoading = true
        errorMessage = nil
        searchResults = []
        
        MaudeAPIService.shared.searchMaudeEvents(
            deviceName: deviceName,
            fromDate: fromDate,
            toDate: toDate
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.errorMessage = error.localizedDescription
            }
        }, receiveValue: { [weak self] events in
            self?.searchResults = events
            if events.isEmpty {
                self?.errorMessage = "No adverse event reports found."
            }
        })
        .store(in: &cancellables)
    }
}
