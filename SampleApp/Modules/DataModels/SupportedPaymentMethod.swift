//
//  SupportedPaymentMethod.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-27.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

/// Payment methods supported in the Sample App
enum SupportedPaymentMethod: String, Identifiable {
    /// Coupon Code / Service Key payment method
    case couponCode
    /// Self insurance payment method
    case insuranceSelf

    public var id: String {
        rawValue
    }
}

extension SupportedPaymentMethod {
    /// Returns a localized title of the payment method
    var localizedTitle: String {
        switch self {
        case .couponCode:
            String(localized: "PaymentMethod.CouponCode.Title")
        case .insuranceSelf:
            String(localized: "PaymentMethod.InsuranceSelf.Title")
        }
    }
}
