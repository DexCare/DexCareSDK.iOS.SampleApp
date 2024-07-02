//
//  InsurancePayer+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-23.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

extension InsurancePayer: Identifiable {
    public var id: String {
        payerId
    }
}
