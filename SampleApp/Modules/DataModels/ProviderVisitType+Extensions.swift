//
//  ProviderVisitType+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-13.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

extension ProviderVisitType: Identifiable {
    /// Note: id and short name are not necessarily unique on their own.
    public var id: String {
        visitTypeId + (shortName?.rawValue ?? "EmptyShortName")
    }
}
