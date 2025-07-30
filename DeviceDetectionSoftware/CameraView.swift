//
//  CameraView.swift
//  DeviceDetectionSoftware
//
//  Created by Tanay Doppalapudi on 7/10/25.
//

import SwiftUI
import AVFoundation

// Custom UIView subclass for automatic preview layer sizing
class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}

struct CameraView: UIViewRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        init(parent: CameraView) { self.parent = parent }
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            parent.onFrame(sampleBuffer)
        }
    }

    let onFrame: (CMSampleBuffer) -> Void

    init(onFrame: @escaping (CMSampleBuffer) -> Void) {
        self.onFrame = onFrame
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> UIView {
        let view = PreviewView()
        view.backgroundColor = UIColor.systemGray6
        let session = AVCaptureSession()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return view }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(output)

        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        // Request camera permission before starting the session
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.global(qos: .userInitiated).async {
                    session.startRunning()
                }
            } else {
                DispatchQueue.main.async {
                    print("❌ Camera access denied")
                }
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.compactMap({ $0 as? AVCaptureVideoPreviewLayer }).first {
            previewLayer.frame = uiView.bounds
        }
    }
}
