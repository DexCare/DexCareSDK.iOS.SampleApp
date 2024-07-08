//
//  Gender+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-15.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

extension Gender: Identifiable {
    public var id: String {
        rawValue
    }
}

extension Gender: CaseIterable {
    public static var allCases: [Gender] = [.male, .female, .other]
}
