// HistContentView.swift
// Main view for searching and displaying FDA historical documents using filters and pagination.

import SwiftUI
import Foundation

struct HistContentView: View {
    // Manages API requests and holds fetched data.
    @StateObject private var fetcher = HistDataFetcher()
    // Search query string.
    @State private var query = ""
    // Selected document type filter.
    @State private var selectedTitle = "All"
    // Selected year filter (used if filterByDate is true).
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    // Whether to show results section.
    @State private var showResults = false
    // Whether to apply year-based filtering.
    @State private var filterByDate = true
    // Controls expansion of the filter section.
    @State private var filtersExpanded = true
    // Controls sorting order of results (true = oldest first).
    @State private var sortAscending: Bool = true

    // UI options and internal mapping for document type filters.
    private let documentTypes = ["All", "Press Release", "Talk"]

    // UI options and internal mapping for document type filters.
    private let docTypeMapping: [String: String] = [
        "Press Release": "pr",
        "Talk": "talk"
    ]

    // Generate a reversed list of years from 1900 to current year for the year slider.
    private var years: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(1900...currentYear).reversed()
    }

    // Sort fetched documents by year according to the selected sort order.
    private var sortedDocuments: [FDADocument] {
        fetcher.documents.sorted {
            sortAscending
                ? ($0.year ?? 0) < ($1.year ?? 0)
                : ($0.year ?? 0) > ($1.year ?? 0)
        }
    }

    // Main view layout including filters, search button, results, and pagination.
    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                DisclosureGroup("Filters", isExpanded: $filtersExpanded) {
                    // Search input and filter controls for document type and year.
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search documents...", text: $query)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }

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

                        Toggle("Filter by Year", isOn: $filterByDate)
                            .padding(.bottom, 4)

                        if filterByDate {
                            Text("Year: \(String(selectedYear))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Slider(
                                value: Binding(
                                    get: { Double(selectedYear) },
                                    set: { selectedYear = Int($0) }
                                ),
                                in: Double(years.last ?? 1900)...Double(years.first ?? selectedYear),
                                step: 1
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.horizontal, 8)
                // Collapse filters when results are shown.
                .animation(.default, value: filtersExpanded)
                .onChange(of: showResults) { newValue in
                    if newValue {
                        filtersExpanded = false
                    }
                }

                // Search button that initiates the fetch request based on selected filters.
                Button(action: {
                    // Map UI selection to backend type parameter.
                    // Reset fetcher state and initiate request.
                    fetcher.errorMessage = nil
                    fetcher.currentPage = 1
                    let titleParam = selectedTitle == "All" ? "" : (docTypeMapping[selectedTitle] ?? "")
                    fetcher.fetchDocuments(
                        query: query,
                        docType: titleParam,
                        startDate: filterByDate ? "\(selectedYear)-01-01" : "",
                        endDate: filterByDate ? "\(selectedYear)-12-31" : "",
                        page: 1
                    )
                    showResults = true
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                        Text("Search").bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 8)
                }
                .disabled(fetcher.isLoading)

                // Allows toggling sort order between oldest and newest first.
                Picker("Sort by Year", selection: $sortAscending) {
                    Text("Oldest First").tag(true)
                    Text("Newest First").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 8)

                // Display total result count if results are loaded.
                if showResults && !fetcher.isLoading && fetcher.errorMessage == nil {
                    Text("Total Results: \(fetcher.totalResults)")
                        .font(.subheadline)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Show loading indicator while fetching.
                if fetcher.isLoading && fetcher.documents.isEmpty {
                    ProgressView("Loading...").padding()
                // Show error message and retry button if fetch fails.
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
                                startDate: filterByDate ? "\(selectedYear)-01-01" : "",
                                endDate: filterByDate ? "\(selectedYear)-12-31" : "",
                                page: fetcher.currentPage
                            )
                        }
                        .padding(.bottom)
                    }
                // Show message if no results are found.
                } else if showResults && fetcher.documents.isEmpty {
                    Text("No documents found.")
                        .foregroundColor(.gray)
                        .padding()
                // List results with navigation to detail view.
                } else if showResults {
                    List(sortedDocuments) { doc in
                        // Each list item shows document type, year, and department, with navigation link.
                        NavigationLink(destination: DocumentDetailView(document: doc)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(doc.displayType)
                                    .font(.headline)
                                Text("Year: \(String (doc.year ?? 0)) – \(doc.department)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    // Load More button for paginating additional results.
                    if fetcher.hasMore {
                        Button(action: {
                            // Trigger fetch for next page using current filters.
                            let titleParam = selectedTitle == "All" ? "" : (docTypeMapping[selectedTitle] ?? "")
                            fetcher.fetchDocuments(
                                query: query,
                                docType: titleParam,
                                startDate: filterByDate ? "\(selectedYear)-01-01" : "",
                                endDate: filterByDate ? "\(selectedYear)-12-31" : "",
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
        // Toolbar button to toggle filter panel visibility.
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    filtersExpanded.toggle()
                } label: {
                    Image(systemName: filtersExpanded
                          ? "line.horizontal.3.decrease.circle.fill"
                          : "line.horizontal.3.decrease.circle")
                }
            }
        }
    }
}
