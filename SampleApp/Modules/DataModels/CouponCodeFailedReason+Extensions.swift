//
//  CouponCodeFailedReason+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-27.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

extension CouponCodeFailedReason {
    /// Returns an alert message for the `CouponCodeFailedReason`
    var alertMessage: String {
        switch self {
        case .unauthorized:
            return String(localized: "CouponCodeFailedReason.Unauthorized.AlertMessage")
        case .notFound:
            return String(localized: "CouponCodeFailedReason.NotFound.AlertMessage")
        case .tooManyRequests:
            return String(localized: "CouponCodeFailedReason.TooManyRequests.AlertMessage")
        case .internalServerError:
            return String(localized: "CouponCodeFailedReason.InternalServerError.AlertMessage")
        case .inactive:
            return String(localized: "CouponCodeFailedReason.Inactive.AlertMessage")
        case let .missingInformation(message: message):
            return message
        case let .failed(reason: reason):
            return reason.errorDescription ?? String(localized: "CouponCodeFailedReason.Failed.AlertMessage")
        }
    }
}
