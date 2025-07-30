//
//  DetectionOverlay.swift
//  DeviceDetectionSoftware
//
//  Created by Tanay Doppalapudi on 7/10/25.
//
import SwiftUI
import Vision

struct DetectionOverlay: View {
    let detections: [VNRecognizedObjectObservation]

    var body: some View {
        GeometryReader { geometry in
            ForEach(detections, id: \.uuid) { detection in
                let rect = detection.boundingBox
                let size = geometry.size
                let boxWidth = rect.width * size.width
                let boxHeight = rect.height * size.height
                let xPos = rect.midX * size.width
                let yPos = (1 - rect.midY) * size.height

                Rectangle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: boxWidth, height: boxHeight)
                    .overlay(
                        Group {
                            if let label = detection.labels.first {
                                Text("\(label.identifier) \(String(format: "%.0f", label.confidence * 100))%")
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.red.opacity(0.7))
                                    .foregroundColor(.white)
                            }
                        },
                        alignment: .topLeading
                    )
                    .position(x: xPos, y: yPos)
            }
        }
    }
}
