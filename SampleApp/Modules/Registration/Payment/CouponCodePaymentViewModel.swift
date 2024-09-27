//
//  CouponCodePaymentViewModel.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-24.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

class CouponCodePaymentViewModel: ObservableObject {
    // MARK: Properties

    @Published var couponCode: String = ""
    private var paymentService: PaymentService
    var presentAlert: ((_ alert: IdentifiableAlert) -> Void)?

    // MARK: Lifecycle

    init(
        couponCode: String = "",
        paymentService: PaymentService = Current.dexcareSDK.paymentService,
        presentAlert: ((_ alert: IdentifiableAlert) -> Void)? = nil
    ) {
        self.couponCode = couponCode
        self.paymentService = paymentService
        self.presentAlert = presentAlert
    }

    // MARK: Internal Methods

    func makePaymentMethod() -> PaymentMethod? {
        .couponCode(couponCode)
    }

    func updateState(paymentMethod: PaymentMethod) {
        switch paymentMethod {
        case let .couponCode(code):
            couponCode = code
        default:
            return
        }
    }

    // swiftlint:disable opening_brace
    func validateStep() -> String? {
        RulesValidator.validate([
            { self.validateCouponCode(self.couponCode) },
        ])
    }

    // swiftlint:enable opening_brace

    func verifyCouponCode() {
        Task { @MainActor in
            do {
                let amountLeft = try await paymentService.verifyCouponCode(couponCode: couponCode)
                let message = String(format: String(localized: "RegistrationStep.CouponCode.WorthMessage"), NumberFormatter.price.string(for: amountLeft) ?? "")
                presentAlert?(.success(message: message))
            } catch {
                presentAlert?(.error(error))
                couponCode = ""
            }
        }
    }

    // MARK: Private

    func validateCouponCode(_ couponCode: String) -> String? {
        couponCode.isEmpty ? String(localized: "RegistrationStep.Field.CouponCode.CannotBeEmptyMessage") : nil
    }
}
