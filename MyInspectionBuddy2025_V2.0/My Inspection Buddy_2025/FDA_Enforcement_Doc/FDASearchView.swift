import SwiftUI

struct FDASearchView: View {
    @StateObject private var viewModel = FDASearchViewModel()

    private var serviceInfo = services.first { $0.name == "FDA Enforcement" }
    private var themeColor: Color { serviceInfo?.color ?? .accentColor }

    var body: some View {
        // The view is now a List to seamlessly integrate the form and results
        List {
            Section(header: Text("Search Criteria")) {
                TextField("Recall Number (e.g., Z-1234-2024)", text: $viewModel.recallNumber)
                TextField("Recalling Firm Name", text: $viewModel.recallingFirm)
                Picker("Classification", selection: $viewModel.selectedClassification) {
                    ForEach(viewModel.classificationOptions, id: \.self) {
                        Text($0)
                    }
                }
            }
            
            Section(header: Text("Date Range")) {
                DatePicker("From", selection: $viewModel.fromDate, displayedComponents: .date)
                DatePicker("To", selection: $viewModel.toDate, displayedComponents: .date)
            }
            
            Section {
                Button(action: {
                    viewModel.executeSearch()
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "magnifyingglass")
                            Text("Search").fontWeight(.bold)
                        }
                        Spacer()
                    }
                }
                .padding(10)
                .background(themeColor)
                .foregroundColor(.white)
                .listRowInsets(EdgeInsets())
            }

            // --- The results list is now here, inside a conditional section ---
            if !viewModel.searchResults.isEmpty {
                Section(header: Text("Found \(viewModel.searchResults.count) Result(s)")) {
                    ForEach(viewModel.searchResults) { recall in
                        // This NavigationLink now correctly finds the RecallDetailView
                        NavigationLink(destination: RecallDetailView(recall: recall)) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(recall.recallingFirm)
                                    .font(.headline)
                                Text(recall.productDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                Text(recall.recallNumber)
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .navigationTitle("FDA Enforcement")
        // --- The old NavigationLink and .onChange logic has been removed ---
        .alert("Search Notice", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        })
    }
}


struct RecallDetailView: View {
    let recall: FDAEnforcementRecord

    var body: some View {
        List {
            Section(header: Text("Recall Summary")) {
                InfoRow(label: "Recall Number", value: recall.recallNumber)
                InfoRow(label: "Status", value: recall.status)
                InfoRow(label: "Classification", value: recall.classification.rawValue)
            }
            
            Section(header: Text("Company Information")) {
                InfoRow(label: "Recalling Firm", value: recall.recallingFirm)
            }
            
            Section(header: Text("Product Information")) {
                 VStack(alignment: .leading, spacing: 5) {
                    Text("Product Description")
                        .font(.headline)
                    Text(recall.productDescription)
                }
                .padding(.vertical, 5)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Code Information")
                        .font(.headline)
                    Text(recall.codeInfo)
                }
                .padding(.vertical, 5)
            }
            
            Section(header: Text("Reason for Recall")) {
                Text(recall.reasonForRecall)
                    .padding(.vertical, 5)
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Recall Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.bold)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}


//import SwiftUI
//
//struct FDASearchView: View {
//    @StateObject private var viewModel = FDASearchViewModel()
//    @State private var showingResults = false
//
//    // Theme color is still used for the search button
//    private var serviceInfo = services.first { $0.name == "FDA Enforcement" }
//    private var themeColor: Color { serviceInfo?.color ?? .accentColor }
//
//    var body: some View {
//        // The view is now just the Form. The SubpageScreen will provide the dock.
//        Form {
//            Section(header: Text("Search Criteria")) {
//                TextField("Recall Number (e.g., Z-1234-2024)", text: $viewModel.recallNumber)
//                TextField("Recalling Firm Name", text: $viewModel.recallingFirm)
//                Picker("Classification", selection: $viewModel.selectedClassification) {
//                    ForEach(viewModel.classificationOptions, id: \.self) {
//                        Text($0)
//                    }
//                }
//            }
//            
//            Section(header: Text("Date Range")) {
//                DatePicker("From", selection: $viewModel.fromDate, displayedComponents: .date)
//                DatePicker("To", selection: $viewModel.toDate, displayedComponents: .date)
//            }
//            
//            Section {
//                Button(action: {
//                    viewModel.executeSearch()
//                }) {
//                    HStack {
//                        Spacer()
//                        if viewModel.isLoading {
//                            ProgressView()
//                                .tint(.white)
//                        } else {
//                            Image(systemName: "magnifyingglass")
//                            Text("Search").fontWeight(.bold)
//                        }
//                        Spacer()
//                    }
//                }
//                .padding(10)
//                .background(themeColor)
//                .foregroundColor(.white)
//                //.clipShape(Capsule())
//                .listRowInsets(EdgeInsets())
//            }
//        }
//        .navigationTitle("FDA Enforcement")
//        // Hidden NavigationLink for showing results
//        .background(
//            NavigationLink(
//                destination: RecallResultsView(recalls: viewModel.searchResults),
//                isActive: $showingResults
//            ) { EmptyView() }
//        )
//        .onChange(of: viewModel.searchResults) { newResults in
//            if !newResults.isEmpty {
//                showingResults = true
//            }
//        }
//        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
//            Button("OK") { viewModel.errorMessage = nil }
//        }, message: {
//            Text(viewModel.errorMessage ?? "An unknown error occurred.")
//        })
//    }
//}
//
//
//#Preview("FDA Search View") {
//    NavigationView {
//        FDASearchView()
//    }
//    .navigationViewStyle(.stack)
//
//}

//import SwiftUI
//
//struct FDASearchView: View {
//    @StateObject private var viewModel = FDASearchViewModel()
//    
//    private var serviceInfo = services.first { $0.name == "FDA Enforcement" }
//    private var themeColor: Color { serviceInfo?.color ?? .accentColor }
//
//    var body: some View {
//        List {
//            Section(header: Text("Search Criteria")) {
//                TextField("Recall Number (e.g., Z-1234-2024)", text: $viewModel.recallNumber)
//                TextField("Recalling Firm Name", text: $viewModel.recallingFirm)
//                Picker("Classification", selection: $viewModel.selectedClassification) {
//                    ForEach(viewModel.classificationOptions, id: \.self) {
//                        Text($0)
//                    }
//                }
//            }
//            
//            Section(header: Text("Date Range")) {
//                DatePicker("From", selection: $viewModel.fromDate, displayedComponents: .date)
//                DatePicker("To", selection: $viewModel.toDate, displayedComponents: .date)
//            }
//            
//            Section {
//                Button(action: {
//                    viewModel.executeSearch()
//                }) {
//                    HStack {
//                        Spacer()
//                        if viewModel.isLoading {
//                            ProgressView()
//                                .tint(.white)
//                        } else {
//                            Image(systemName: "magnifyingglass")
//                            Text("Search").fontWeight(.bold)
//                        }
//                        Spacer()
//                    }
//                }
//                .padding(10)
//                .background(themeColor)
//                .foregroundColor(.white)
//                .listRowInsets(EdgeInsets())
//            }
//            
//            if !viewModel.searchResults.isEmpty {
//                Section(header: Text("Found \(viewModel.searchResults.count) Result(s)")) {
//                    ForEach(viewModel.searchResults) { recall in
//                        // This NavigationLink now correctly finds the RecallDetailView
//                        NavigationLink(destination: RecallDetailView(recall: recall)) {
//                            VStack(alignment: .leading, spacing: 5) {
//                                Text(recall.recallingFirm)
//                                    .font(.headline)
//                                Text(recall.productDescription)
//                                    .font(.subheadline)
//                                    .foregroundColor(.secondary)
//                                    .lineLimit(2)
//                                Text(recall.recallNumber)
//                                    .font(.caption)
//                                    .foregroundColor(.accentColor)
//                            }
//                            .padding(.vertical, 4)
//                        }
//                    }
//                }
//            }
//        }
//        .navigationTitle("FDA Enforcement")
//        .alert("Search Notice", isPresented: .constant(viewModel.errorMessage != nil), actions: {
//            Button("OK") { viewModel.errorMessage = nil }
//        }, message: {
//            Text(viewModel.errorMessage ?? "An unknown error occurred.")
//        })
//    }
//}
//
//// --- ADD THE DEFINITIONS FROM THE OLD FILE HERE ---
//
//struct RecallDetailView: View {
//    let recall: FDAEnforcementRecord
//
//    var body: some View {
//        List {
//            Section(header: Text("Recall Summary")) {
//                InfoRow(label: "Recall Number", value: recall.recallNumber)
//                InfoRow(label: "Status", value: recall.status)
//                InfoRow(label: "Classification", value: recall.classification.rawValue)
//            }
//            
//            Section(header: Text("Company Information")) {
//                InfoRow(label: "Recalling Firm", value: recall.recallingFirm)
//            }
//            
//            Section(header: Text("Product Information")) {
//                 VStack(alignment: .leading, spacing: 5) {
//                    Text("Product Description")
//                        .font(.headline)
//                    Text(recall.productDescription)
//                }
//                .padding(.vertical, 5)
//
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("Code Information")
//                        .font(.headline)
//                    Text(recall.codeInfo)
//                }
//                .padding(.vertical, 5)
//            }
//            
//            Section(header: Text("Reason for Recall")) {
//                Text(recall.reasonForRecall)
//                    .padding(.vertical, 5)
//            }
//        }
//        .listStyle(.grouped)
//        .navigationTitle("Recall Details")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//struct InfoRow: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        HStack {
//            Text(label)
//                .fontWeight(.bold)
//            Spacer()
//            Text(value)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.trailing)
//        }
//    }
//}
//
//
//#Preview("FDA Search View") {
//    NavigationView {
//        FDASearchView()
//    }
//    .navigationViewStyle(.stack)
//}
