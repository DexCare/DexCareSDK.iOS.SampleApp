//
//  UIApplication+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-12.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation
import SwiftUI

extension UIApplication {
    /// Returns the active scene root view controller
    /// Notes:
    ///   - This extension is needed at the moment so that we can get the virtual visit presenting view controller
    var firstKeyWindowRootViewController: UIViewController? {
        let windowScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        let activeScene = windowScenes
            .filter { $0.activationState == .foregroundActive }
        let firstActiveScene = activeScene.first
        let keyWindow = firstActiveScene?.keyWindow
        return keyWindow?.rootViewController
    }
}
