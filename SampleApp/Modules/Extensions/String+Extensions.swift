//
//  String+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-15.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

extension String: Identifiable {
    public var id: String { self }
}

/// This extension allow us to throw and handle strings has `Error`.
extension String: LocalizedError {
    public var errorDescription: String? { self }
}
