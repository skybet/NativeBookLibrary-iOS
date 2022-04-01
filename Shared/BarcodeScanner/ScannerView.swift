//
//  ScannerView.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 10/03/2022.
//

import SwiftUI

struct ScannerView: View {
    @Binding var showScanner: Bool
    @Binding var scannedValue: String?

    @StateObject private var viewModel = ScannerViewModel()

    var body: some View {
        VStack {
            Spacer()

            Text("Scan the books barcode")
                .font(.headline)

#if canImport(UIKit)
            BarcodeScannerView()
                .found(r: viewModel.foundBarcode)
                .torchLight(isOn: viewModel.isTorchOn)
                .interval(delay: viewModel.scanInterval)
                .overlay {
                    GeometryReader { proxy in
                        Rectangle()
                            .stroke(viewModel.lastScannedBarcode.isEmpty ? Color.barcodeFinderSearching : Color.barcodeFinderFound, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .bevel, dash: [30, proxy.size.width - 60, 60, proxy.size.height - 60, 60, proxy.size.width - 60, 60, proxy.size.height - 60, 30], dashPhase: 0))
                    }
                }
                .overlay {
                    Rectangle()
                        .fill(.red)
                        .frame(height: 0.5)
                }
                .aspectRatio(1.5, contentMode: .fit)
#endif

            Button(action: {
                viewModel.isTorchOn.toggle()
            }, label: {
                Image(systemName: viewModel.isTorchOn ? "bolt.fill" : "bolt.slash.fill")
                    .imageScale(.large)
                    .foregroundColor(viewModel.isTorchOn ? .yellow : .gray)
                    .padding()
            })

            Spacer()

            Button(action: {
                scannedValue = viewModel.lastScannedBarcode
                showScanner = false
            }, label: {
                Label("Confirm", systemImage: "checkmark")
                    .foregroundColor(.white)
                    .opacity(viewModel.lastScannedBarcode.isEmpty ? 0.7 : 1)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(viewModel.lastScannedBarcode.isEmpty ? .gray : .barcodeFinderFound)
                    )
            })
            .disabled(viewModel.lastScannedBarcode.isEmpty)
        }
        .padding()
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView(showScanner: .constant(true), scannedValue: .constant(nil))
    }
}
