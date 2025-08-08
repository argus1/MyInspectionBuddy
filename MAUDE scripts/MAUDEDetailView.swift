import SwiftUI

struct MAUDEDetailView: View {
    let keyword: String
    let fromDate: String?
    let toDate: String?
    let newestFirst: Bool

    @State private var results: [MAUDEEvent] = []
    @State private var totalCount = 0
    @State private var page = 0
    @State private var isLoading = false

    let api = APIManager()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                Text("Results for '\(keyword)'")
                    .font(.headline)
                    .padding(.top)

                ForEach(results, id: \.id) { event in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Report #: \(event.report_number)").bold()
                        Text("Date Received: \(event.date_received)").underline()
                        Text("Event Type: \(event.event_type)").underline()

                        if let device = event.device.first {
                            Text("Brand: \(device.brand_name ?? "")")
                                .italic()
                            Text("Generic: \(device.generic_name ?? "")")
                                .italic()
                        }

                        ShareLink(item: "Report #: \(event.report_number)\n\(event.date_received) — \(event.event_type)") {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .font(.footnote)
                        .padding(.top, 4)
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
        .background(Color(.systemGroupedBackground))
        .onAppear {
            search(reset: true)
        }
    }

    func search(reset: Bool) {
        if reset {
            results = []
            page = 0
        }

        isLoading = true
        api.searchMAUDE(
            keyword: keyword,
            fromDate: fromDate,
            toDate: toDate,
            newestFirst: newestFirst,
            skip: page * 10
        ) { events, count in
            results += events
            totalCount = count
            page += 1
            isLoading = false
        }
    }
}
