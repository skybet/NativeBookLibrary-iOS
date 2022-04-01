//
//  CameraPreview.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 11/03/2022.
//

#if canImport(UIKit)
import UIKit
import AVFoundation

class CameraPreview: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?
    var session: AVCaptureSession

    weak var delegate: ScannerCameraDelegate?

    private var label: UILabel?

    init(session: AVCaptureSession = AVCaptureSession()) {
        self.session = session
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        #if targetEnvironment(simulator)
            label?.frame = bounds
        #else
            previewLayer?.frame = bounds
        #endif
    }

    func createSimulatorView(delegate: ScannerCameraDelegate) {
        self.delegate = delegate
        backgroundColor = .black
        makeLabel()
    }

    private func makeLabel() {
        let label = UILabel(frame: bounds)
        label.numberOfLines = 4
        label.text = "Click here to simulate scan"
        label.textColor = .white
        label.textAlignment = .center

        let gesture = UITapGestureRecognizer(target: self, action: #selector(onClick))
        self.addGestureRecognizer(gesture)

        addSubview(label)
        self.label = label
    }

    @objc private func onClick(){
        delegate?.onSimulateScanning()
    }
}
#endif
