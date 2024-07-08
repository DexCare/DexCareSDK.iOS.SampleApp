//
//  VirtualVisitFailedReason+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-23.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import SwiftUI

extension VirtualVisitFailedReason {
    /// Returns an alert message for the `VirtualVisitFailedReason`
    var alertMessage: String {
        switch self {
        case .incompleteRequestData:
            return String(localized: "VirtualVisitFailedReason.IncompleteRequestData.AlertMessage")
        case let .missingInformation(message):
            return String(format: String(localized: "FailedReason.MissingInformation.AlertMessage"), message)
        case .invalidEmail:
            return String(localized: "VirtualVisitFailedReason.InvalidEmail.AlertMessage")
        case .expired:
            return String(localized: "VirtualVisitFailedReason.Expired.AlertMessage")
        case .regionBusy:
            return String(localized: "VirtualVisitFailedReason.RegionBusy.AlertMessage")
        case .permissionDenied:
            return String(localized: "VirtualVisitFailedReason.PermissionDenied.AlertMessage")
        case let .failed(failedReason):
            return failedReason.alertMessage
        case .virtualVisitNotFound:
            return String(localized: "VirtualVisitFailedReason.VirtualVisitNotFound.AlertMessage")
        case .visitTypeNotSupported:
            return String(localized: "VirtualVisitFailedReason.VisitTypeNotSupported.AlertMessage")
        case let .invalidRequest(message):
            return message
        }
    }
}
