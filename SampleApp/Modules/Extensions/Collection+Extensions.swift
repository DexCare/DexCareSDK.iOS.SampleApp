//
//  Collection+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-14.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
