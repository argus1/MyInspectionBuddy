//
// RegistrationDetailView.swift
// Displays detailed information for a single FDARegistration including company and product info.
//

import SwiftUI

// Main view struct for displaying the detailed FDA registration data.
struct RegistrationDetailView: View {
    // The FDARegistration object passed in to display its details.
    let registration: FDARegistration

    // The main body of the view; displays information grouped by sections.
    var body: some View {
        List {
            // MARK: - Registration Info
            // Section displaying general registration information including number, type, and location.
            Section(header: Text("Registration Info")) {
                // Row for displaying the registration number.
                HStack {
                    Image(systemName: "number.circle")
                    Text("Registration Number")
                    Spacer()
                    Text(registration.registrationNumber)
                        .foregroundStyle(.secondary)
                }

                if let types = registration.establishmentType, !types.isEmpty {
                    // Row for each establishment type (looped).
                    ForEach(types, id: \.self) { type in
                        HStack {
                            Image(systemName: "building.2")
                            Text("Establishment Type")
                            Spacer()
                            Text(type)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    // Row indicating no establishment types available.
                    HStack {
                        Image(systemName: "building.2")
                        Text("Establishment Type")
                        Spacer()
                        Text("None")
                            .foregroundStyle(.secondary)
                    }
                }

                // Row for displaying the company name.
                HStack {
                    Image(systemName: "building")
                    Text("Company Name")
                    Spacer()
                    Text(registration.registrationName)
                        .foregroundStyle(.secondary)
                }
                // Row for displaying the FEI number.
                HStack {
                    Image(systemName: "number.circle")
                    Text("FEI Number")
                    Spacer()
                    Text(registration.feiNumber)
                        .foregroundStyle(.secondary)
                }
                // Row for displaying the country of registration.
                HStack {
                    Image(systemName: "globe")
                    Text("Country")
                    Spacer()
                    Text(registration.registration?.isoCountryCode ?? "—")
                        .foregroundStyle(.secondary)
                }
                // Row for displaying the state of registration.
                HStack {
                    Image(systemName: "map")
                    Text("State")
                    Spacer()
                    Text(registration.registration?.stateCode ?? "—")
                        .foregroundStyle(.secondary)
                }
                // Row for displaying the US agent's name.
                HStack {
                    Image(systemName: "person.crop.circle")
                    Text("US Agent Name")
                    Spacer()
                    Text(registration.usAgentName)
                        .foregroundStyle(.secondary)
                }
                // Row for displaying the registration expiry year.
                HStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                    Text("Expiry Year")
                    Spacer()
                    Text(registration.expiryYear ?? "—")
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: - Products
            // Section displaying detailed information for each associated product.
            Section(header: Text("Products")) {
                if let products = registration.products, !products.isEmpty {
                    ForEach(products.indices, id: \.self) { idx in
                        let product = products[idx]
                        VStack(alignment: .leading, spacing: 4) {
                            // Product: Device name.
                            HStack {
                                Image(systemName: "ipad.and.iphone")
                                Text("Device Name")
                                Spacer()
                                Text(product.openfda?.deviceName ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                            // Product: Product code.
                            HStack {
                                Image(systemName: "tag")
                                Text("Product Code")
                                Spacer()
                                Text(product.productCode ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                            // Product: Regulation number.
                            HStack {
                                Image(systemName: "gavel")
                                Text("Regulation #")
                                Spacer()
                                Text(product.openfda?.regulationNumber ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                            // Product: Device class.
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Device Class")
                                Spacer()
                                Text(product.openfda?.deviceClass ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                            // Product: Creation date.
                            HStack {
                                Image(systemName: "calendar")
                                Text("Creation Date")
                                Spacer()
                                Text(product.createdDate ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                            // Product: Owner operator firm name.
                            HStack {
                                Image(systemName: "person.2")
                                Text("Owner Operator Firm")
                                Spacer()
                                Text(registration.ownerOperatorFirmName ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    // Row indicating no products available.
                    HStack {
                        Image(systemName: "archivebox")
                        Text("Products")
                        Spacer()
                        Text("None")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        // Set the navigation bar title for the detail view.
        .navigationTitle("Details")
    }
}
