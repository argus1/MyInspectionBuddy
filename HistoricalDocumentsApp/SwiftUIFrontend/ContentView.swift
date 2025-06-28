// MARK: - FDADocument Extension
extension FDADocument {
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
import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var fetcher = HistDataFetcher()
    @State private var query = ""
    @State private var selectedTitle = "All"
    @State private var startYear: Int = Calendar.current.component(.year, from: Date()) - 10
    @State private var endYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showResults = false
    @State private var filterByDate = true
    @State private var filtersExpanded = true
    @State private var sortAscending: Bool = true

    // Only "Press Release" and "Talk" types are available.
    private let documentTypes = ["All", "Press Release", "Talk"]

    private let docTypeMapping: [String: String] = [
        "Press Release": "pr",
        "Talk": "talk"
    ]

    private var years: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(1900...currentYear).reversed()
    }

    private var sortedDocuments: [FDADocument] {
        fetcher.documents.sorted {
            sortAscending
                ? ($0.year ?? 0) < ($1.year ?? 0)
                : ($0.year ?? 0) > ($1.year ?? 0)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                DisclosureGroup("Filters", isExpanded: $filtersExpanded) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Search Bar
                        TextField("Search documents...", text: $query)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 8)

                        // Title Picker
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

                        Toggle("Filter by Date", isOn: $filterByDate)
                            .padding(.bottom, 4)

                        if filterByDate {
                            Text("Year Range: \(NumberFormatter.localizedString(from: NSNumber(value: startYear), number: .none)) – \(NumberFormatter.localizedString(from: NSNumber(value: endYear), number: .none))")
                                .font(.subheadline)
                                .foregroundColor(.gray)

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
                // Search Button
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

                Picker("Sort by Year", selection: $sortAscending) {
                    Text("Oldest First").tag(true)
                    Text("Newest First").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 8)

                // Results Count
                if showResults && !fetcher.isLoading && fetcher.errorMessage == nil {
                    Text("Total Results: \(fetcher.totalResults)")
                        .font(.subheadline)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Results List
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
                    }

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

                Spacer()
            }
            .navigationTitle("FDA Historical Docs")
        }
    }

    private func formattedYear(_ year: Int, isStart: Bool) -> String {
        return isStart ? "\(year)-01-01" : "\(year)-12-31"
    }
}
