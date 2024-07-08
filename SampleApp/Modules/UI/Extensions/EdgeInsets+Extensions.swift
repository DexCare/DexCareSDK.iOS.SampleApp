//
//  EdgeInsets+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-08.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation
import SwiftUI

extension EdgeInsets {
    /// Creates an `EdgeInsets` instes where all sides are the same dimension
    init(all edge: CGFloat) {
        self.init(top: edge, leading: edge, bottom: edge, trailing: edge)
    }
}
