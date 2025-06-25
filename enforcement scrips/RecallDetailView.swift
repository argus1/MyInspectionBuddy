import SwiftUI
//display details

struct RecallDetailView: View {
    let recall: Recall

    var body: some View {
        List {
            Section(header: Text("Recall Summary")) {
                InfoRow(label: "Recall Number", value: recall.recall_number)
                InfoRow(label: "Status", value: recall.status)
                InfoRow(label: "Classification", value: recall.classification)
            }
            
            Section(header: Text("Company Information")) {
                InfoRow(label: "Recalling Firm", value: recall.recalling_firm)
            }
            
            Section(header: Text("Product Information")) {
                 VStack(alignment: .leading, spacing: 5) {
                    Text("Product Description")
                        .font(.headline)
                    Text(recall.product_description)
                }
                .padding(.vertical, 5)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Code Information")
                        .font(.headline)
                    Text(recall.code_info)
                }
                .padding(.vertical, 5)
            }
            
            Section(header: Text("Reason for Recall")) {
                Text(recall.reason_for_recall)
                    .padding(.vertical, 5)
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Recall Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.bold)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}
