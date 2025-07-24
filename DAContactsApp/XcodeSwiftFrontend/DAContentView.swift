// DAContentView.swift
// This file defines the main view of the DAContactsApp.
// It provides search functionality, displays the user's county, and shows local and filtered contact data.

import SwiftUI
import CoreLocation

// LocationManager handles permission requests and retrieves the user's county using CoreLocation.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userCounty: String?

    // Initialize CLLocationManager and request location permission.
    override init() {
        super.init()
        manager.delegate = self
        print("🗺️ [LM] init: asking for permission…")
        manager.requestWhenInUseAuthorization()
    }

    // Called when location authorization changes; starts location updates if authorized.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("🔑 [LM] auth changed to \(status.rawValue) — \(status)")
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ [LM] authorized, starting updates")
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("⛔️ [LM] permission denied/restricted")
        default:
            break
        }
    }

    // Handles location update failure.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ [LM] didFailWithError:", error.localizedDescription)
    }

    // Called with updated location; uses reverse geocoding to determine the county.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        CLGeocoder().reverseGeocodeLocation(loc) { placemarks, _ in
            if var county = placemarks?.first?.subAdministrativeArea {
                if county.hasSuffix(" County") {
                    county = String(county.dropLast(" County".count))
                }
                print("🌎 [LM] normalized userCounty =", county)
                DispatchQueue.main.async {
                    self.userCounty = county
                }
            } else {
                print("⚠️ [LM] no county found in placemark")
            }
        }
        manager.stopUpdatingLocation()
    }
}

// DAContentView is the main UI for displaying contact search, location info, and contact list.
struct DAContentView: View {
    // Access shared ContactViewModel from environment.
    @EnvironmentObject var viewModel: ContactViewModel
    // StateObject for managing the user's location via LocationManager.
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // UI field for searching by name.
                HStack {
                    Image(systemName: "person.text.rectangle")
                        .foregroundColor(.gray)
                    TextField("Search by name", text: $viewModel.searchName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)

                // UI field for searching by county.
                HStack {
                    Image(systemName: "map")
                        .foregroundColor(.gray)
                    TextField("Search by county", text: $viewModel.searchCounty)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding([.horizontal, .bottom])

                // Section displaying user's current county location.
                HStack(spacing: 8) {
                    Image(systemName: "location.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        if let county = locationManager.userCounty {
                            Text("Your current location is in:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(county) County")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        } else {
                            Text("Detecting your current location...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Display a special card for the user's local contact, if available.
                if let county = locationManager.userCounty,
                   let localContact = viewModel.contacts.first(where: { $0.county == county }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Local Contact")
                            .font(.headline)
                            .padding(.horizontal)
                        NavigationLink(destination: ContactDetailView(contact: localContact)) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(localContact.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(localContact.county)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 8)
                }

                // List of all filtered contacts with NavigationLinks to their detail views.
                List(viewModel.filteredContacts) { contact in
                    NavigationLink(destination: ContactDetailView(contact: contact)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text(contact.name)
                                    .font(.headline)
                            }

                            HStack {
                                Image(systemName: "location.fill")
                                Text(contact.county)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            HStack {
                                Image(systemName: "phone.fill")
                                Text(contact.phone)
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowSeparator(.visible)
                }
                .listStyle(.insetGrouped)
            }
            .navigationBarTitle("DA Contacts", displayMode: .inline)
            // Fetch contacts when the view appears.
            .onAppear {
                viewModel.fetchContacts()
            }
            // When the county is detected, prioritize showing local contacts first.
            .onReceive(locationManager.$userCounty.compactMap { $0 }) { userCounty in
                // Partition contacts into local vs. non-local
                let localContacts = viewModel.contacts.filter { $0.county == userCounty }
                let otherContacts = viewModel.contacts.filter { $0.county != userCounty }
                // Reassemble with local first
                DispatchQueue.main.async {
                    viewModel.contacts = localContacts + otherContacts
                }
            }
        }
    }
}
