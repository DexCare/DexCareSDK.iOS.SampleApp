//
//  View+LayoutPriority.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-27.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation
import SwiftUI

/// Predefined layout priorities.
public enum LayoutPriority: CGFloat {
    case low = 250
    case high = 750
    case required = 1000
}

extension View {
    /// Applies a layout priority using a subset of pre-defined values
    @inlinable
    func layoutPriority(_ layoutPriority: LayoutPriority) -> some View {
        self.layoutPriority(layoutPriority.rawValue)
    }
}
