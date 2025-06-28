import SwiftUI

struct MaudeResultsView: View {
    let events: [MaudeEvent]

    var body: some View {
        List(events) { event in
            VStack(alignment: .leading, spacing: 8) {
                
                // Brand Name first and with largest font
                Text(event.device.first?.brandName ?? "Unknown Brand")
                    .font(.headline)
                    .fontWeight(.bold)

                // Generic Name
                Text("Generic: \(event.device.first?.genericName ?? "N/A")")
                    .font(.subheadline)
                
                //Report number
                Text("Report #: \(event.reportNumber ?? "N/A")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let modelNumber = event.device.first?.modelNumber {
                    Text("Model #: \(modelNumber)")
                        .font(.subheadline)
                }
                
                if let productCode = event.device.first?.deviceReportProductCode {
                    Text("Product Class: \(productCode)")
                        .font(.subheadline)
                }
                
                if let exemption = event.device.first?.exemptionNumber {
                     Text("Exemption #: \(exemption)")
                        .font(.subheadline)
                }
                
                // Date and Event Type on the same line
                HStack {
                    Text("Date: \(event.dateReceived)")
                    Spacer()
                    if let eventType = event.eventType {
                        Text(eventType)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(eventTypeColor(eventType))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4) // Add some space above this line
            }
            .padding(.vertical, 8)
        }
    }
    
    private func eventTypeColor(_ eventType: String) -> Color {
        switch eventType.lowercased() {
        case "death":
            return .red
        case "injury":
            return .orange
        case "malfunction":
            return .blue
        default:
            return .gray
        }
    }
}

