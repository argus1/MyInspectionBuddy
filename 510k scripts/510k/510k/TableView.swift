//
//  TableView.swift
//  510k
//
//  Created by Nicole Tang on 6/23/25.
//


import SwiftUI

struct TableView: View {
    let results: [FDA510kResult]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("K Number").bold().frame(width: 100, alignment: .leading)
                Text("Date").bold().frame(width: 100, alignment: .leading)
                Text("Applicant").bold().frame(width: 180, alignment: .leading)
                Text("Device Name").bold().frame(width: 180, alignment: .leading)
            }
            Divider()

            ForEach(results) { result in
                HStack {
                    Text(result.kNumber ?? "—").frame(width: 100, alignment: .leading)
                    Text(result.decisionDate ?? "—").frame(width: 100, alignment: .leading)
                    Text(result.applicant ?? "—").frame(width: 180, alignment: .leading)
                    Text(result.deviceName ?? "—").frame(width: 180, alignment: .leading)
                }
                Divider()
            }
        }
        .padding()
    }
}
