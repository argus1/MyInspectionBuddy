import SwiftUI

struct MAUDESearchInputView: View {
    @State private var deviceName = ""
    @State private var enableDateFilter = false
    @State private var yearRange: ClosedRange<Int> = 2000...2025
    @State private var selectedRange: ClosedRange<Int> = 2010...2025
    @State private var sortNewestFirst = true
    @State private var showResults = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("MAUDE Search")
                        .font(.title.bold())

                    TextField("Device Generic Name (Required)", text: $deviceName)
                        .textFieldStyle(.roundedBorder)

                    Toggle("Filter by Date", isOn: $enableDateFilter)
                        .font(.subheadline.bold())

                    if enableDateFilter {
                        VStack(alignment: .leading) {
                            Text("Year Range: \(selectedRange.lowerBound) – \(selectedRange.upperBound)")
                                .font(.caption)

                            Slider(value: Binding(
                                get: { Double(selectedRange.lowerBound) },
                                set: { selectedRange = Int($0)...selectedRange.upperBound }
                            ), in: Double(yearRange.lowerBound)...Double(yearRange.upperBound))

                            Slider(value: Binding(
                                get: { Double(selectedRange.upperBound) },
                                set: { selectedRange = selectedRange.lowerBound...Int($0) }
                            ), in: Double(yearRange.lowerBound)...Double(yearRange.upperBound))
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
                        if !deviceName.isEmpty {
                            showResults = true
                        }
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
                .padding()
                .navigationDestination(isPresented: $showResults) {
                    MAUDEDetailView(
                        keyword: deviceName,
                        fromDate: enableDateFilter ? "\(selectedRange.lowerBound)0101" : nil,
                        toDate: enableDateFilter ? "\(selectedRange.upperBound)1231" : nil,
                        newestFirst: sortNewestFirst
                    )
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}
