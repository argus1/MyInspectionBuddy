import SwiftUI

@main
struct MAUDEDeviceSearchApp: App {
    var body: some Scene {
        WindowGroup {
            MAUDESearchInputView()
        }
    }
}

struct ContentView: View {
    @State private var deviceName = ""
    @State private var enableDateFilter = false
    @State private var yearRange: ClosedRange<Int> = 2000...2025
    @State private var selectedRange: ClosedRange<Int> = 2010...2025
    @State private var sortNewestFirst = true
    @State private var results: [MAUDEEvent] = []
    @State private var isLoading = false
    @State private var totalCount = 0
    @State private var page = 0

    let api = APIManager()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 🔍 Search Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("MAUDE Search")
                        .font(.title.bold())

                    TextField("Device Generic Name (Required)", text: $deviceName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Toggle(isOn: $enableDateFilter) {
                        Text("Filter by Date").bold()
                    }

                    if enableDateFilter {
                        VStack(alignment: .leading) {
                            Text("Year Range: \(selectedRange.lowerBound) – \(selectedRange.upperBound)")
                                .font(.caption)

                            Slider(value: Binding(
                                get: { Double(selectedRange.lowerBound) },
                                set: { selectedRange = Int($0)...selectedRange.upperBound }
                            ), in: Double(yearRange.lowerBound)...Double(yearRange.upperBound), step: 1)

                            Slider(value: Binding(
                                get: { Double(selectedRange.upperBound) },
                                set: { selectedRange = selectedRange.lowerBound...Int($0) }
                            ), in: Double(yearRange.lowerBound)...Double(yearRange.upperBound), step: 1)
                        }
                    }

                    HStack {
                        Text("Oldest First")
                            .foregroundColor(!sortNewestFirst ? .primary : .gray)
                            .onTapGesture { sortNewestFirst = false }

                        Spacer()

                        Text("Newest First")
                            .foregroundColor(sortNewestFirst ? .primary : .gray)
                            .onTapGesture { sortNewestFirst = true }
                    }
                    .font(.footnote)

                    Button(action: {
                        search(reset: true)
                    }) {
                        Text("Search")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
                .padding(.top)

                // 🧾 Results
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                }

                ScrollView {
                    LazyVStack(spacing: 12) {
                        if totalCount > 0 {
                            Text("Total Results: \(totalCount)")
                                .font(.caption)
                        }

                        ForEach(results) { event in
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Report #: \(event.report_number)")
                                    .bold()
                                Text("Date Received: ").underline() + Text(event.date_received)
                                Text("Event Type: ").underline() + Text(event.event_type)

                                if let device = event.device.first {
                                    if let brand = device.brand_name {
                                        Text("Brand: \(brand)").italic()
                                    }
                                    if let generic = device.generic_name {
                                        Text("Generic: \(generic)").italic()
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                            .padding(.horizontal)
                        }

                        if results.count < totalCount {
                            Button("Load More") {
                                search(reset: false)
                            }
                            .padding()
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    func search(reset: Bool) {
        guard !deviceName.isEmpty else { return }

        if reset {
            results = []
            page = 0
        }

        isLoading = true

        let from = enableDateFilter ? "\(selectedRange.lowerBound)0101" : nil
        let to = enableDateFilter ? "\(selectedRange.upperBound)1231" : nil

        api.searchMAUDE(
            keyword: deviceName,
            fromDate: from,
            toDate: to,
            newestFirst: sortNewestFirst,
            skip: page * 10
        ) { events, count in
            results += events
            totalCount = count
            page += 1
            isLoading = false
        }
    }
}
