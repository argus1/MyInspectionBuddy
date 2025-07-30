//
//  DeviceDetectionContentView.swift
//  DeviceDetectionSoftware
//
//  Created by Tanay Doppalapudi on 7/10/25.
//

import SwiftUI

struct DDContentView: View {
    @StateObject private var detectionVM = DetectionViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Device Detection")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.top, .horizontal])

            ZStack {
                CameraView(onFrame: detectionVM.handleFrame)
                    .cornerRadius(10)
                DetectionOverlay(detections: detectionVM.detections)
                    .cornerRadius(10)
            }
            .frame(height: UIScreen.main.bounds.height * 0.6)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .padding()

            Spacer()
        }
    }
}
