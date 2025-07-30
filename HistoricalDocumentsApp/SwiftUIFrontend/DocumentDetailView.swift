//
// SwiftUI view to display detailed information about an FDA document, including metadata, body text, and actions for dragging, copying, and sharing.
import SwiftUI
import Foundation

// Main detail view for an FDADocument: shows title, year, effective date, full text, and supports drag/copy/share.
struct DocumentDetailView: View {
    // The document to display in this view.
    let document: FDADocument
    // State flag to control presentation of the iOS share sheet.
    @State private var isShareSheetPresented = false

    var body: some View {
        // Scrollable container for document details.
        ScrollView {
            // Vertical stack to layout header, metadata, and body text.
            VStack(alignment: .leading, spacing: 20) {
                // Header section: title and metadata of the document.
                Group {
                    // Display the document title or fallback to docType.
                    Text(document.title ?? document.docType?.capitalized ?? "Document")
                        .font(.title)
                        .bold()

                    // Show the document's year if available.
                    if let year = document.year {
                        Text("Year: \(NumberFormatter.localizedString(from: NSNumber(value: year), number: .none))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // Show the document's effective date if available.
                    if let effectiveDate = document.effectiveDate {
                        Text("Effective Date: \(effectiveDate)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // Visual separator between header and body.
                Divider()

                // Section header for the full document text.
                Text("Document Text")
                    .font(.headline)

                // Display the body of the document with line wrapping.
                Text(document.text ?? "No content available.")
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                // Pushes content to the top within the ScrollView.
                Spacer()
            }
            .padding()
            // Enable drag-and-drop of the document object.
            .draggable(document)
        }
        // Set the navigation bar title for this view.
        .navigationTitle("Document Detail")
        // Toolbar with actions for copying info and sharing text.
        .toolbar {
            // Copy the document's formatted info to the clipboard.
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    UIPasteboard.general.string = document.formattedInfo()
                }) {
                    Image(systemName: "doc.on.doc")
                }
            }
            // Show the iOS share sheet to share the document text.
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShareSheetPresented = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(document.text == nil)
            }
        }
        // Present the share sheet when triggered.
        .sheet(isPresented: $isShareSheetPresented) {
            if let text = document.text {
                ActivityView(activityItems: [text])
            }
        }
    }
}

// Wrapper to present UIActivityViewController for sharing content.
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Create and return the UIKit share sheet controller.
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update logic needed for the share sheet.
    }
}
