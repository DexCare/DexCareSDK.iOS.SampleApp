//
//  View+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-15.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    /// Applie a certain block of code to your view
    /// For example
    /// ```
    ///  MyView().apply {
    ///    if #available(iOS 17.0, *) {
    ///        $0.someiOS17Modifier()
    ///    } else {
    ///        $0
    ///    }
    ///  }
    /// ```
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V {
        block(self)
    }
}
