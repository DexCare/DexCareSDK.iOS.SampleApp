//
//  FailedReason+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-23.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import SwiftUI

public extension FailedReason {
    /// Returns an alert message for the `FailedReason`
    var alertMessage: String {
        switch self {
        case .unauthorized:
            return String(localized: "FailedReason.Unauthorized.AlertMessage")
        case .notFound:
            return String(localized: "FailedReason.NotFound.AlertMessage")
        case let .unknown(reason):
            return String(format: String(localized: "FailedReason.Unknown.AlertMessage"), reason.localizedDescription)
        case let .missingInformation(message):
            return String(format: String(localized: "FailedReason.MissingInformation.AlertMessage"), message)
        case .badRequest:
            return String(localized: "FailedReason.BadRequest.AlertMessage")
        case let .badDexcareRequest(info):
            return String(format: String(localized: "FailedReason.BadDexcareRequest.AlertMessage"), info.message, info.errorCode)
        case let .invalidInput(message):
            return String(format: String(localized: "FailedReason.InvalidInput.AlertMessage"), message)
        }
    }
}
