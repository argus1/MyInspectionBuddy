//
//  DetectionViewModel.swift
//  DeviceDetectionSoftware
//
//  Created by Tanay Doppalapudi on 7/10/25.
//
import Foundation
import Vision
import CoreML
import AVFoundation

class DetectionViewModel: ObservableObject {
    @Published var detections: [VNRecognizedObjectObservation] = []
    
    private let visionModel: VNCoreMLModel
    
    private lazy var request: VNCoreMLRequest = {
        let req = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
            DispatchQueue.main.async {
                self?.detections = results
            }
        }
        req.imageCropAndScaleOption = .scaleFill
        return req
    }()

    init() {
        // Load the Core ML model generated from MyInspectionBuddy.mlpackage
        let config = MLModelConfiguration()
        guard let coreMLModel = try? MyInspectionBuddy(configuration: config).model,
              let visionModel = try? VNCoreMLModel(for: coreMLModel) else {
            fatalError("Failed to load MyInspectionBuddy model")
        }
        self.visionModel = visionModel
    }

    /// Call this for each camera frame to run the ML model
    func handleFrame(_ buffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .right,
                                            options: [:])
        do {
            try handler.perform([self.request])
        } catch {
            print("Vision request failed:", error)
        }
    }
}
