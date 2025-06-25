import SwiftUI


struct FDASearchView: View {
    @StateObject private var viewModel = FDASearchViewModel()
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Search Criteria")) {
                    TextField("Recall Number (e.g., Z-1234-2024)", text: $viewModel.recallNumber)
                        .keyboardType(.asciiCapable)
                    
                    TextField("Recalling Firm Name", text: $viewModel.recallingFirm)
                    
                    Picker("Classification", selection: $viewModel.selectedClassification) {
                        ForEach(viewModel.classificationOptions, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section(header: Text("Classification Date Range")) {
                    DatePicker("From", selection: $viewModel.fromDate, displayedComponents: .date)
                    DatePicker("To", selection: $viewModel.toDate, displayedComponents: .date)
                }
            }
            
            if viewModel.isLoading {
                ProgressView("Searching...")
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if !viewModel.searchResults.isEmpty {
                RecallResultsView(recalls: viewModel.searchResults)
            }
            
            Spacer()
        }
        .navigationTitle("FDA Enforcement Database Search")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.executeSearch()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "magnifyingglass")
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
}
