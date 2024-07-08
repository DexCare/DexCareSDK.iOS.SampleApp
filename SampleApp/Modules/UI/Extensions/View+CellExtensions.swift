//
//  View+CellExtensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-13.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

extension View {
    /// Cell views default shadow.
    func cellShadow() -> some View {
        shadow(color: .dxShadow, radius: 2, x: 0, y: 2)
    }
}
