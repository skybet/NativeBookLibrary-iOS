//
//  BarcodeScannerView.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 11/03/2022.
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewRepresentable {
    var supportedBarcodeTypes: [AVMetadataObject.ObjectType] = [.ean8, .ean13]
    typealias UIViewType = CameraPreview

    private let session = AVCaptureSession()
    private let delegate = ScannerCameraDelegate()
    private let metadataOutput = AVCaptureMetadataOutput()

    // MARK: - View modifiers
    func torchLight(isOn: Bool) -> BarcodeScannerView {
        if let backCamera = AVCaptureDevice.default(for: .video) {
            if backCamera.hasTorch {
                try? backCamera.lockForConfiguration()

                if isOn {
                    backCamera.torchMode = .on
                } else {
                    backCamera.torchMode = .off
                }

                backCamera.unlockForConfiguration()
            }
        }

        return self
    }

    func interval(delay: Double) -> BarcodeScannerView {
        delegate.scanInterval = delay
        return self
    }

    func found(r: @escaping (String) -> Void) -> BarcodeScannerView {
        delegate.onResult = r
        return self
    }

    func simulator(mockBarCode: String) -> BarcodeScannerView{
        delegate.mockData = mockBarCode
        return self
    }

    private func setupCamera(_ uiView: CameraPreview) {
        guard
            let backCamera = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: backCamera)
        else { return }

        session.sessionPreset = .photo

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)

            metadataOutput.metadataObjectTypes = supportedBarcodeTypes
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: .main)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)

        uiView.backgroundColor = .gray
        previewLayer.videoGravity = .resizeAspectFill
        uiView.layer.addSublayer(previewLayer)
        uiView.previewLayer = previewLayer

        session.startRunning()
    }

    func makeUIView(context: UIViewRepresentableContext<BarcodeScannerView>) -> BarcodeScannerView.UIViewType {
        let cameraView = CameraPreview(session: session)

        #if targetEnvironment(simulator)
            cameraView.createSimulatorView(delegate: delegate)
        #else
            checkCameraAuthorizationStatus(cameraView)
        #endif

        return cameraView
    }

    static func dismantleUIView(_ uiView: CameraPreview, coordinator: ()) {
        uiView.session.stopRunning()
    }

    private func checkCameraAuthorizationStatus(_ uiView: CameraPreview) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        if cameraAuthorizationStatus == .authorized {
            setupCamera(uiView)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.sync {
                    if granted {
                        self.setupCamera(uiView)
                    }
                }
            }
        }
    }

    func updateUIView(_ uiView: CameraPreview, context: UIViewRepresentableContext<BarcodeScannerView>) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
}
