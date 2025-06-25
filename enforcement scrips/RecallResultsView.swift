import SwiftUI

//display search results
struct RecallResultsView: View {
    let recalls: [Recall]

    var body: some View {
        List(recalls) { recall in
            NavigationLink(destination: RecallDetailView(recall: recall)) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(recall.recalling_firm)
                        .font(.headline)
                    Text(recall.product_description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    Text(recall.recall_number)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
                .padding(.vertical, 4)
            }
        }
    }
}
