//
//  SearchDBView.swift
//  CDPHrecalldb
//
//  Created by Nicole Tang on 6/25/25.
//


import SwiftUI

struct SearchDBView: View {
    @State private var month = ""
    @State private var year = ""
    @State private var company = ""
    @State private var device = ""
    @State private var results: [Recall] = []
    @State private var sortOption: String = "item"

    let columns: [GridItem] = [
        GridItem(.flexible(minimum: 80)),
        GridItem(.flexible(minimum: 60)),
        GridItem(.flexible(minimum: 60)),
        GridItem(.flexible(minimum: 100))
    ]

    let sortOptions = ["item", "month", "year"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("CDPH Device Recall Search")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("SEARCH DEVICE RECALLS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)

                VStack(spacing: 12) {
                    Menu {
                        ForEach([
                            "January", "February", "March", "April",
                            "May", "June", "July", "August",
                            "September", "October", "November", "December"
                        ], id: \.self) { m in
                            Button(m) { month = m }
                        }
                    } label: {
                        HStack {
                            Text(month.isEmpty ? "Month (e.g. May)" : month)
                                .foregroundColor(month.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    }
                    .pickerStyle(.menu)

                    TextField("Year (e.g. 2025)", text: $year)
                        .textFieldStyle(.roundedBorder)
                    TextField("Company Name", text: $company)
                        .textFieldStyle(.roundedBorder)
                    TextField("Device Name", text: $device)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Button("Search") {
                        let rawResults = DatabaseQuery.search(
                            month: month,
                            year: year,
                            company: company,
                            device: device
                        )
                        results = rawResults.map {
                            Recall(
                                id: Int.random(in: 10000...99999),
                                item: $0["item"] ?? "Unknown",
                                month: $0["month"],
                                year: $0["year"],
                                recallURL: $0["recall_url"] ?? ""
                            )
                        }
                        sortResults()
                    }

                    Picker("Sort by", selection: $sortOption) {
                        ForEach(sortOptions, id: \.self) { option in
                            Text(option.capitalized)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: sortOption) { _ in
                        sortResults()
                    }
                }

                if !results.isEmpty {
                    Text("RESULTS")
                        .font(.headline)
                        .padding(.top)

                    LazyVGrid(columns: columns, spacing: 12) {
                        Group {
                            Text("Item").bold()
                            Text("Month").bold()
                            Text("Year").bold()
                            Text("Link").bold()
                        }

                        ForEach(results) { rec in
                            Text(rec.item)
                            Text(rec.month ?? "")
                            Text(rec.year ?? "")
                            Link("View PDF", destination: URL(string: rec.recallURL)!)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical)
                }

                Spacer()
            }
            .padding(30)
        }
    }

    private func sortResults() {
        let monthOrder: [String: Int] = [
            "January": 1, "February": 2, "March": 3, "April": 4,
            "May": 5, "June": 6, "July": 7, "August": 8,
            "September": 9, "October": 10, "November": 11, "December": 12
        ]

        switch sortOption {
        case "month":
            results.sort {
                let m1 = monthOrder[$0.month ?? ""] ?? 13
                let m2 = monthOrder[$1.month ?? ""] ?? 13
                return m1 < m2
            }
        case "year":
            results.sort {
                let y1 = Int($0.year ?? "") ?? 0
                let y2 = Int($1.year ?? "") ?? 0
                return y1 > y2  // descending
            }
        default:
            results.sort { $0.item < $1.item }
        }
    }

}


struct Recall: Identifiable {
    let id: Int
    let item: String
    let month: String?
    let year: String?
    let recallURL: String
}
