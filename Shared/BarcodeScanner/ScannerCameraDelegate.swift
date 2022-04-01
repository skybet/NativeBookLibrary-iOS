//
//  ScannerCameraDelegate.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 11/03/2022.
//

#if canImport(UIKit)
import AVFoundation

class ScannerCameraDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var scanInterval: Double = 1
    var lastScanTime = Date(timeIntervalSince1970: 0)

    var onResult: (String) -> Void = { _  in }
    var mockData: String?

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard
            let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let value = readableObject.stringValue
        else { return }

        barcodeFound(value)
    }

    private func barcodeFound(_ value: String) {
        let now = Date()

        if now.timeIntervalSince(lastScanTime) >= scanInterval {
            lastScanTime = now
            onResult(value)
        }
    }

    func onSimulateScanning() {
        barcodeFound(mockData ?? "Simulated QR-code result.")
    }
}
#endif
