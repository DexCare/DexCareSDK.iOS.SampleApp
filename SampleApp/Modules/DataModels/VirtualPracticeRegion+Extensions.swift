//
//  VirtualPracticeRegion+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-15.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

extension VirtualPracticeRegion: Identifiable {
    public var id: String {
        practiceRegionId
    }
}
