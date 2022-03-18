//
//  Haptics.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 18/03/2022.
//

import Foundation

#if os(iOS)
import UIKit
#endif

class Haptics {
    static func success() {
#if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
#endif
    }
}
