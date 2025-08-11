import SwiftUI

struct SearchHistorySidebar: View {
    let searchHistory: [HistoryItem]
    let themeColor: Color
    var onSelectHistoryItem: (HistoryItem) -> Void
    var onClearHistory: () -> Void
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Search History").font(.headline)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
            }
            .padding()
            
            if searchHistory.isEmpty {
                Spacer()
                Text("No history yet.").foregroundColor(.secondary).frame(maxWidth: .infinity)
                Spacer()
            } else {
                List {
                    ForEach(searchHistory) { item in
                        Button(action: { onSelectHistoryItem(item) }) {
                            VStack(alignment: .leading) {
                                Text(item.searchTerm.isEmpty ? "Any Keyword" : item.searchTerm)
                                    .font(.subheadline).fontWeight(.bold).foregroundColor(.primary)
                                Text("Type: \(item.docType ?? "All")")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                
                Button(action: onClearHistory) {
                    Text("Clear History").font(.headline).foregroundColor(.red).frame(maxWidth: .infinity)
                }
                .padding()
            }
        }
        .frame(width: 280)
        .background(Color(.systemGroupedBackground))
        .transition(.move(edge: .trailing))
    }
}
