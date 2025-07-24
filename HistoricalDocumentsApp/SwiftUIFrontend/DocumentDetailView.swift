//
// DocumentDetailView.swift
// Displays details of an FDADocument including title, date, content, and a share button.
//

import SwiftUI
import Foundation
import UIKit

// Main SwiftUI view that shows document metadata and full body text in a scrollable layout.
struct DocumentDetailView: View {
    let document: FDADocument
    // Tracks whether the share sheet is currently presented.
    @State private var isShareSheetPresented = false

    // Constructs the UI layout including title, metadata, body content, and toolbar.
    var body: some View {
        // Scrollable content view for reading long text documents.
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Document title and metadata section.
                Group {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                        Text(document.title ?? document.displayType)
                            .font(.title)
                            .bold()
                    }

                    if let year = document.year {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            // Display the year of the document, if available.
                            Text("Year: \(String(year))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    if let effectiveDate = document.effectiveDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar.badge.clock")
                            // Display the effective date of the document, if available.
                            Text("Effective Date: \(effectiveDate)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Divider separates metadata from document body content.
                Divider()

                // Section header for document body content.
                HStack(spacing: 6) {
                    Image(systemName: "doc.append")
                    Text("Document Text")
                        .font(.headline)
                }

                // Main text content of the document or fallback message if empty.
                Text(document.cleanBody.isEmpty ? "No content available." : document.cleanBody)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Document Detail")
        // Toolbar with share button to present ActivityView.
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShareSheetPresented = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                // Disable share button if there is no text to share.
                .disabled(document.text == nil)
            }
        }
        // Conditionally present a share sheet with the full text of the document.
        .sheet(isPresented: $isShareSheetPresented) {
            if let text = document.text {
                ActivityView(activityItems: [text])
            }
        }
    }
}

// Wrapper to present UIActivityViewController in SwiftUI.
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    // Create and return a configured UIActivityViewController.
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    // No update logic needed for static activity view.
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
