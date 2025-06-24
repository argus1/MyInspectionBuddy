//
//  UnifiedSearchView.swift
//  510k
//
//  Created by Nicole Tang on 6/23/25.
//


import SwiftUI

enum SortOption: String, CaseIterable {
    case applicant = "Applicant"
    case device = "Device Name"
    case date = "Decision Date"
}

struct UnifiedSearchView: View {
    @State private var fromDate: Date? = nil
    @State private var toDate: Date? = nil
    @State private var showingFromPicker = false
    @State private var showingToPicker = false

    @State private var applicantName = ""
    @State private var deviceName = ""
    
    @State private var results: [FDA510kResult] = []
    @State private var message = ""
    @State private var isLoading = false
    @State private var sortOption: SortOption = .applicant

    private let apiKey = "e3oka6wF312QcwuJguDeXVEN6XGyeJC94Hirijj8"

    var body: some View {
        NavigationStack {
            Form {
                // Date input
                Section(header: Text("Select Date Range")) {
                    Button(action: { showingFromPicker.toggle() }) {
                        HStack {
                            Text("From")
                            Spacer()
                            Text(fromDate.map { formattedDate($0) } ?? "Select Date")
                                .foregroundColor(.gray)
                        }
                    }

                    if showingFromPicker {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { fromDate ?? Date() },
                                set: { fromDate = $0 }
                            ),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                    }

                    Button(action: { showingToPicker.toggle() }) {
                        HStack {
                            Text("To")
                            Spacer()
                            Text(toDate.map { formattedDate($0) } ?? "Select Date")
                                .foregroundColor(.gray)
                        }
                    }

                    if showingToPicker {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { toDate ?? (fromDate ?? Date()) },
                                set: { toDate = $0 }
                            ),
                            in: (fromDate ?? Date())...,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                    }
                }

                // Text input
                Section(header: Text("Applicant Name")) {
                    TextField("Company Name", text: $applicantName)
                }

                Section(header: Text("Device Name")) {
                    TextField("Device Name", text: $deviceName).autocapitalization(.none)
                }

                // Search and sort
                Section {
                    Button("Search FDA") {
                        Task { await performUnifiedSearch() }
                    }

                    Menu("Sort By: \(sortOption.rawValue)") {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(option.rawValue) {
                                sortOption = option
                                sortResults()
                            }
                        }
                    }
                }

                // Loading & Message
                if isLoading {
                    ProgressView("Loading...")
                }

                if !message.isEmpty {
                    Text(message).foregroundColor(.secondary)
                }

                // Results
                if !results.isEmpty {
                    Section(header: Text("Results")) {
                        ScrollView([.horizontal, .vertical]) {
                            TableView(results: results)
                        }
                    }
                }
            }
            .navigationTitle("FDA 510k Search")
        }
    }

    // MARK: - Date Formatter
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // MARK: - API Search
    func performUnifiedSearch() async {
        isLoading = true
        results = []
        message = ""
        defer { isLoading = false }

        var queryParts: [String] = []

        if let from = fromDate, let to = toDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            let minDate = formatter.string(from: from)
            let maxDate = formatter.string(from: to)
            queryParts.append("decision_date:[\(minDate)+TO+\(maxDate)]")
        }

        if !applicantName.isEmpty {
            queryParts.append("applicant:\"\(applicantName)\"")
        }

        if !deviceName.isEmpty {
            queryParts.append("device_name:\"\(deviceName)\"")
        }

        guard !queryParts.isEmpty else {
            message = "Please enter at least one search criterion."
            return
        }

        let rawQuery = queryParts.joined(separator: "+AND+")
        let encodedQuery = rawQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.fda.gov/device/510k.json?api_key=\(apiKey)&search=\(encodedQuery)&limit=25"

        if let fetched = await fetchResults(from: urlString) {
            results = fetched
            sortResults()
            message = fetched.isEmpty ? "No results found." : ""
        } else {
            message = "Error retrieving data."
        }
    }

    // MARK: - Fetch Results
    func fetchResults(from urlString: String) async -> [FDA510kResult]? {
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let rawResults = json?["results"] as? [[String: Any]] else { return [] }

            let jsonData = try JSONSerialization.data(withJSONObject: rawResults)
            return try JSONDecoder().decode([FDA510kResult].self, from: jsonData)
        } catch {
            print("Error decoding: \(error)")
            return nil
        }
    }

    // MARK: - Sort Results
    func sortResults() {
        switch sortOption {
        case .applicant:
            results.sort { ($0.applicant ?? "") < ($1.applicant ?? "") }
        case .device:
            results.sort { ($0.deviceName ?? "") < ($1.deviceName ?? "") }
        case .date:
            results.sort { ($0.decisionDate ?? "") < ($1.decisionDate ?? "") }
        }
    }
}

