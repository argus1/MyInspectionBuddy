import SwiftUI

struct MaudeSearchView: View {
    @StateObject private var viewModel = MaudeSearchViewModel()
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Search Criteria")) {
                    TextField("Device Generic Name (Required)", text: $viewModel.deviceName)
                }
                
                Section(header: Text("Date Received Range")) {
                    DatePicker("From", selection: $viewModel.fromDate, displayedComponents: .date)
                    DatePicker("To", selection: $viewModel.toDate, in: viewModel.fromDate..., displayedComponents: .date)
                }
            }
            .frame(maxHeight: 250)

            if viewModel.isLoading {
                ProgressView("Searching MAUDE...")
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.secondary)
                    .padding()
            } else if !viewModel.searchResults.isEmpty {
                VStack {
                    Link("View full details on openFDA", destination: URL(string: "https://open.fda.gov/apis/device/event/explore-the-api-with-an-interactive-chart/")!)
                        .font(.callout)
                        .padding()
                    
                    MaudeResultsView(events: viewModel.searchResults)
                }
            }
            
            Spacer()
        }
        .navigationTitle("MAUDE Search")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Search", action: viewModel.executeSearch)
                    .disabled(viewModel.isLoading)
            }
        }
    }
}
