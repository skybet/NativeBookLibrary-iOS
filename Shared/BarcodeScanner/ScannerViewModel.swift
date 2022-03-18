//
//  ScannerViewModel.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 10/03/2022.
//

import Foundation

class ScannerViewModel: ObservableObject {
    @Published var isTorchOn = false
    @Published var lastScannedBarcode = ""

    let scanInterval: Double = 1

    func foundBarcode(_ barcode: String) {
        lastScannedBarcode = barcode

        DispatchQueue.main.async {
            Haptics.success()
        }
    }
}
