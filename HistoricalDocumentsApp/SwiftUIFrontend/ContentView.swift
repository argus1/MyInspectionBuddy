// MARK: - FDADocument computed properties
// Extensions providing helper properties to format document metadata.
extension FDADocument {
    // Maps the raw docType string to a human-readable document type.
    var displayType: String {
        switch docType?.lowercased() {
        case "pr":
            return "Press Release"
        case "pha":
            return "Public Health Alert"
        case "cn":
            return "Compliance Notice"
        case "sw":
            return "Safety Warning"
        case "talk":
            return "Talk"
        default:
            return docType?.capitalized ?? "Unknown"
        }
    }

    // Extracts the first non-empty line from the document text as the department.
    var department: String {
        guard let text = text else { return "Unknown" }
        let lines = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return lines.first ?? "Unknown"
    }
}

extension FDADocument {
    // Cleans the document body by removing empty and short lines for readability.
    /// Cleaned body text: remove empty lines and lines with few alphabetic characters
    var cleanBody: String {
        guard let raw = text else { return "" }
        let lines = raw.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let filtered = lines.filter { line in
            // keep lines with at least 4 letters
            let letterCount = line.unicodeScalars.filter { CharacterSet.letters.contains($0) }.count
            return letterCount >= 4
        }
        return filtered.joined(separator: "\n\n")
    }
}

// SwiftUI view for browsing and filtering FDA historical documents.
// Imports required for SwiftUI and core functionality.
import SwiftUI
import Foundation

// Main view displaying filter controls and document results.
struct ContentView: View {
    // State properties for managing filters, queries, and view state.
    @StateObject private var fetcher = HistDataFetcher()
    @State private var query = ""
    @State private var selectedTitle = "All"
    @State private var startYear: Int = Calendar.current.component(.year, from: Date()) - 10
    @State private var endYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showResults = false
    @State private var filterByDate = true
    @State private var filtersExpanded = true
    @State private var sortAscending: Bool = true

    // Constants for the document type picker and mapping to API parameters.
    // Only "Press Release" and "Talk" types are available.
    private let documentTypes = ["All", "Press Release", "Talk"]

    private let docTypeMapping: [String: String] = [
        "Press Release": "pr",
        "Talk": "talk"
    ]

    // Generates a reversed list of years from 1900 to the current year for date filtering.
    private var years: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(1900...currentYear).reversed()
    }

    // Sorts fetched documents by year based on the selected sort order.
    private var sortedDocuments: [FDADocument] {
        fetcher.documents.sorted {
            sortAscending
                ? ($0.year ?? 0) < ($1.year ?? 0)
                : ($0.year ?? 0) > ($1.year ?? 0)
        }
    }

    var body: some View {
        // Navigation container for the content view.
        NavigationView {
            VStack(spacing: 8) {
                // Filter section: search query, document type, and date range controls.
                DisclosureGroup("Filters", isExpanded: $filtersExpanded) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Text field for entering a search query.
                        TextField("Search documents...", text: $query)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 8)

                        // Picker to select the document type filter.
                        VStack(alignment: .leading) {
                            Text("Document Type")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Picker("Document Type", selection: $selectedTitle) {
                                ForEach(documentTypes, id: \.self) { type in
                                    Text(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding(.horizontal, 8)

                        // Toggle to enable or disable filtering by date range.
                        Toggle("Filter by Date", isOn: $filterByDate)
                            .padding(.bottom, 4)

                        if filterByDate {
                            Text("Year Range: \(NumberFormatter.localizedString(from: NSNumber(value: startYear), number: .none)) – \(NumberFormatter.localizedString(from: NSNumber(value: endYear), number: .none))")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            // Sliders to adjust the start and end year for filtering.
                            // Start Year Slider
                            Slider(
                                value: Binding(
                                    get: { Double(startYear) },
                                    set: { startYear = Int($0) }
                                ),
                                in: Double(years.last ?? 1900)...Double(years.first ?? Calendar.current.component(.year, from: Date())),
                                step: 1
                            )

                            // End Year Slider
                            Slider(
                                value: Binding(
                                    get: { Double(endYear) },
                                    set: { endYear = Int($0) }
                                ),
                                in: Double(startYear)...Double(years.first ?? Calendar.current.component(.year, from: Date())),
                                step: 1
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.horizontal, 8)
                .animation(.default, value: filtersExpanded)
                .onChange(of: showResults) { newValue in
                    if newValue {
                        filtersExpanded = false
                    }
                }
                // Initiates the API fetch with the current filter settings.
                Button(action: {
                    guard startYear <= endYear else {
                        fetcher.errorMessage = "Start year must be before end year."
                        return
                    }
                    fetcher.errorMessage = nil
                    fetcher.currentPage = 1
                    let titleParam = selectedTitle == "All" ? "" : (docTypeMapping[selectedTitle] ?? "")
                    fetcher.fetchDocuments(
                        query: query,
                        docType: titleParam,
                        startDate: filterByDate ? formattedYear(startYear, isStart: true) : "",
                        endDate: filterByDate ? formattedYear(endYear, isStart: false) : "",
                        page: 1
                    )
                    showResults = true
                }) {
                    Text("Search")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal, 8)
                }
                .disabled(fetcher.isLoading)

                // Segmented control to choose sort order (oldest or newest first).
                Picker("Sort by Year", selection: $sortAscending) {
                    Text("Oldest First").tag(true)
                    Text("Newest First").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 8)

                // Displays the total number of results returned.
                if showResults && !fetcher.isLoading && fetcher.errorMessage == nil {
                    Text("Total Results: \(fetcher.totalResults)")
                        .font(.subheadline)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Show loading indicator, error message, or "No documents found" as needed.
                if fetcher.isLoading && fetcher.documents.isEmpty {
                    ProgressView("Loading...")
                        .padding()
                } else if let error = fetcher.errorMessage {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                        Button("Retry") {
                            let titleParam = selectedTitle == "All" ? "" : (docTypeMapping[selectedTitle] ?? "")
                            fetcher.fetchDocuments(
                                query: query,
                                docType: titleParam,
                                startDate: formattedYear(startYear, isStart: true),
                                endDate: formattedYear(endYear, isStart: false),
                                page: fetcher.currentPage
                            )
                        }
                        .padding(.bottom)
                    }
                } else if showResults && fetcher.documents.isEmpty {
                    Text("No documents found.")
                        .foregroundColor(.gray)
                        .padding()
                } else if showResults {
                    // List to display each document with drag and copy capabilities.
                    List(sortedDocuments) { doc in
                        NavigationLink(destination: DocumentDetailView(document: doc)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(doc.displayType) – \(doc.department)")
                                        .font(.headline)
                                    Text("\(NumberFormatter.localizedString(from: NSNumber(value: doc.year ?? 0), number: .none)) – \(doc.department)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        // Enables drag-out of the document and a context menu to copy info.
                        .draggable(doc)
                        // Add context menu for copying info
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = doc.formattedInfo()
                            }) {
                                Label("Copy Info", systemImage: "doc.on.doc")
                            }
                        }
                    }

                    // Loads the next page of results for pagination.
                    if fetcher.hasMore {
                        Button(action: {
                            let titleParam = selectedTitle == "All" ? "" : (docTypeMapping[selectedTitle] ?? "")
                            fetcher.fetchDocuments(
                                query: query,
                                docType: titleParam,
                                startDate: formattedYear(startYear, isStart: true),
                                endDate: formattedYear(endYear, isStart: false),
                                page: fetcher.currentPage + 1
                            )
                        }) {
                            Text(fetcher.isLoading ? "Loading..." : "Load More")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(fetcher.isLoading ? Color.gray : Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        .disabled(fetcher.isLoading)
                    }
                }

                // Pushes content to the top of the view.
                Spacer()
            }
            .navigationTitle("FDA Historical Docs")
        }
    }

    // Helper function to format year values into API date strings.
    private func formattedYear(_ year: Int, isStart: Bool) -> String {
        return isStart ? "\(year)-01-01" : "\(year)-12-31"
    }
}
