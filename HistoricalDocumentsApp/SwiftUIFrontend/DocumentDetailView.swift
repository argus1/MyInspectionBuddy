//
//  DocumentDetailView.swift
//  HistoricalDocsApp
//
//  Created by Tanay Doppalapudi on 6/19/25.
//
import SwiftUI
import Foundation

struct DocumentDetailView: View {
    let document: FDADocument
    @State private var isShareSheetPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text(document.title ?? document.docType?.capitalized ?? "Document")
                        .font(.title)
                        .bold()

                    if let year = document.year {
                        Text("Year: \(NumberFormatter.localizedString(from: NSNumber(value: year), number: .none))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if let effectiveDate = document.effectiveDate {
                        Text("Effective Date: \(effectiveDate)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                Text("Document Text")
                    .font(.headline)

                Text(document.text ?? "No content available.")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Document Detail")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShareSheetPresented = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(document.text == nil)
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            if let text = document.text {
                ActivityView(activityItems: [text])
            }
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
