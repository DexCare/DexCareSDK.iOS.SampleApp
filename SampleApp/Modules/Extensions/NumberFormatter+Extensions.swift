//
//  NumberFormatter+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-19.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

extension NumberFormatter {
    /// For example, $99.00
    static let price = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
}
