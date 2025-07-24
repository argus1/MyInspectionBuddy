//
// RegListContentView.swift
// Displays the main user interface for searching and viewing FDA registration listings.
//
//  ContentView.swift
//  LicensingDatabaseApp
//
//  Created by Tanay Doppalapudi on 7/8/25.
//  Updated by ChatGPT on 7/11/25.
//

import SwiftUI

// Main view that includes filters, results summary, and the registration list.
struct RegListContentView: View {
    // View model managing the search state and API data.
    @StateObject private var viewModel = RegistrationViewModel()
    
    // Stores the input value for filtering by registration number.
    @State private var filterByRegistrationNumber = ""
    // Stores the input value for filtering by state.
    @State private var filterByState              = "CA"   // Default to California (operator)
    // Stores the input value for filtering by country.
    @State private var filterByCountry            = ""
    // Stores the input value for filtering by company.
    @State private var filterByCompany            = ""    // Registration name
    // Stores the input value for filtering by FEI.
    @State private var filterByFEI                = ""
    // Stores the input value for filtering by device name.
    @State private var filterByDeviceName         = ""
    // Stores the input value for filtering by US agent name.
    @State private var filterByUSAgentName        = ""
    // Stores the input value for filtering by creation date.
    @State private var filterByCreationDate       = ""    // YYYY format
    // Stores the input value for filtering by expiry year.
    @State private var filterByExpiryYear         = ""    // Reg expiry year
    @State private var filtersExpanded            = true
    
    // Layout for the overall UI including filters, results count, and registration list.
    var body: some View {
        NavigationView {
            VStack {
                // Toggle button for collapsing/expanding filters
                HStack {
                    Button(action: { filtersExpanded.toggle() }) {
                        Label(
                            filtersExpanded ? "Hide Filters" : "Show Filters",
                            systemImage: filtersExpanded ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle"
                        )
                        .font(.headline)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // Conditionally show filters
                if filtersExpanded {
                    FiltersView(
                        filterByRegistrationNumber: $filterByRegistrationNumber,
                        filterByState:              $filterByState,
                        filterByCountry:            $filterByCountry,
                        filterByCompany:            $filterByCompany,
                        filterByFEI:                $filterByFEI,
                        filterByDeviceName:         $filterByDeviceName,
                        filterByUSAgentName:        $filterByUSAgentName,
                        filterByCreationDate:       $filterByCreationDate,
                        filterByExpiryYear:         $filterByExpiryYear,
                        applyFilters: {
                            applyFilters()
                            filtersExpanded = false
                        }
                    )
                }
                
                // Results count and list
                if viewModel.totalCount > 0 {
                    Text("Total Results: \(viewModel.totalCount)")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                }
                
                // Show inline message when no results are found
                if viewModel.registrations.isEmpty && viewModel.didTriggerSearch {
                    Text("No results found. Try broadening your search criteria.")
                        .foregroundStyle(.secondary)
                        .padding()
                }
                
                RegistrationListView(viewModel: viewModel)
            }
            // Set navigation bar title and styling.
            .navigationTitle("Registration Listings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Registration Listings")
                        .font(.title2)
                }
            }
        }
    }
    
    // Builds the query string from active filter values and triggers a search.
    private func applyFilters() {
        var parts: [String] = []
        
        // Create OR clause for location filters (state or country)
        let locationQueries = [
            filterByState.isEmpty   ? nil : "registration.us_agent.state_code:\"\(filterByState)\"",
            filterByCountry.isEmpty ? nil : "registration.iso_country_code:\"\(filterByCountry)\""
        ].compactMap { $0 }
        
        if !locationQueries.isEmpty {
            let orQuery = locationQueries.joined(separator: " OR ")
            parts.append(locationQueries.count == 1 ? orQuery : "(\(orQuery))")
        }
        
        // Registration Number
        if !filterByRegistrationNumber.isEmpty {
            let input = filterByRegistrationNumber.trimmingCharacters(in: .whitespaces)
            if Int(input) != nil {
                // Match exact numeric registration number
                parts.append("registration.registration_number:\"\(input)\"")
            } else {
                // Wildcard text search for registration number
                parts.append("registration.registration_number:\"\(input)*\"")
            }
        }
        
        // Company (Registration Name)
        if !filterByCompany.isEmpty {
            parts.append("registration.name:\"\(filterByCompany)*\"")
        }
        
        // FEI Number
        if !filterByFEI.isEmpty {
            let input = filterByFEI.trimmingCharacters(in: .whitespaces)
            if Int(input) != nil {
                parts.append("registration.fei_number:\"\(input)\"")
            } else {
                parts.append("registration.fei_number:\"\(input)*\"")
            }
        }
        
        // Device Name
        if !filterByDeviceName.isEmpty {
            parts.append("proprietary_name:\"\(filterByDeviceName)*\"")
        }
        
        // US Agent Name
        if !filterByUSAgentName.isEmpty {
            parts.append("registration.us_agent.name:\"\(filterByUSAgentName)*\"")
        }
        
        // Creation Year
        if !filterByCreationDate.isEmpty {
            let year = filterByCreationDate.trimmingCharacters(in: .whitespaces)
            if year.count == 4, Int(year) != nil {
                parts.append("products.created_date:[\(year)-01-01 TO \(year)-12-31]")
            } else {
                parts.append("products.created_date:\"\(filterByCreationDate)*\"")
            }
        }
        
        // Expiry Year
        if !filterByExpiryYear.isEmpty {
            let year = filterByExpiryYear.trimmingCharacters(in: .whitespaces)
            if year.count == 4, Int(year) != nil {
                parts.append("registration.reg_expiry_date_year:[\(year) TO \(year)]")
            } else {
                parts.append("registration.reg_expiry_date_year:\"\(filterByExpiryYear)*\"")
            }
        }
        
        // Construct final query string with +AND+
        let finalQuery = parts.joined(separator: "+AND+")
        print("Submitting query: \(finalQuery)")
        Task { await viewModel.search(finalQuery) }
    }
}

// MARK: – Filters UI
// UI form for user-entered filter fields and control buttons.
private struct FiltersView: View {
    @Binding var filterByRegistrationNumber: String
    @Binding var filterByState: String
    @Binding var filterByCountry: String
    @Binding var filterByCompany: String
    @Binding var filterByFEI: String
    @Binding var filterByDeviceName: String
    @Binding var filterByUSAgentName: String
    @Binding var filterByCreationDate: String
    @Binding var filterByExpiryYear: String
    let applyFilters: () -> Void

    @State private var showMoreFilters = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Filters", systemImage: "line.horizontal.3.decrease.circle")
                .font(.headline)
            
            // Core filters
            Group {
                // Text field for registration number
                TextField("Registration #", text: $filterByRegistrationNumber)
                HStack(spacing: 8) {
                    // Text field for US Agent State Code
                    TextField("US Agent State Code (e.g. CA)", text: $filterByState)
                        .frame(maxWidth: .infinity)
                    // Text field for Country Code
                    TextField("Country Code (e.g. US)", text: $filterByCountry)
                        .frame(maxWidth: .infinity)
                }
                // Text field for FEI Number
                TextField("FEI Number", text: $filterByFEI)
                // Text field for Creation Year
                TextField("Creation Year (YYYY)", text: $filterByCreationDate)
            }
            .textFieldStyle(.roundedBorder)
            
            // Toggle for showing advanced filters
            Button(action: { showMoreFilters.toggle() }) {
                Label(
                    showMoreFilters ? "Hide more filtering options" : "More filtering options",
                    systemImage: showMoreFilters ? "chevron.up.circle" : "chevron.down.circle"
                )
                .font(.subheadline)
            }
            .padding(.vertical, 4)
            
            if showMoreFilters {
                Group {
                    // Text field for Registration Name
                    TextField("Registration Name", text: $filterByCompany)
                    // Text field for Device Name
                    TextField("Device Name", text: $filterByDeviceName)
                    // Text field for US Agent Name
                    TextField("US Agent Name", text: $filterByUSAgentName)
                    // Text field for Expiry Year
                    TextField("Expiry Year (YYYY)", text: $filterByExpiryYear)
                }
                .textFieldStyle(.roundedBorder)
            }
            
            // Apply filters button
            Button(action: applyFilters) {
                Label("Apply Filters", systemImage: "slider.horizontal.3")
            }
            .padding(.vertical, 4)
        }
        .padding()
    }
}

// MARK: – List
// Displays the paginated list of search results and handles navigation to detail view.
private struct RegistrationListView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    
    var body: some View {
        List {
            // Each list row shows the device name and registration number
            ForEach(viewModel.registrations) { reg in
                NavigationLink(destination: RegistrationDetailView(registration: reg)) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading) {
                            Text(reg.products?.first?.openfda?.deviceName
                                 ?? reg.proprietaryName?.first
                                 ?? "Unknown Device")
                                .font(.headline)
                            Text("Registration #: \(reg.registrationNumber)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                // Triggers loading more results when near end of list
                .task { await viewModel.loadMoreIfNeeded(currentItem: reg) }
            }
            
            // Loading spinner when more results are being fetched
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .listStyle(.plain)
    }
}
