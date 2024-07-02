//
//  InsuranceViewPaymentModel.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-23.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

struct InsuranceViewPaymentState {
    var memberId: String
    var groupId: String
    var selectedInsurancePayer: InsurancePayer? {
        didSet {
            selectedInsurancePayerString = selectedInsurancePayer?.name ?? String(localized: "RegistrationStep.Field.InsurancePayers.Instructions")
        }
    }

    var selectedInsurancePayerString: String

    init(memberId: String, groupId: String, selectedInsurancePayer: InsurancePayer? = nil) {
        self.memberId = memberId
        self.groupId = groupId
        self.selectedInsurancePayer = selectedInsurancePayer
        selectedInsurancePayerString = selectedInsurancePayer?.name ?? String(localized: "RegistrationStep.Field.InsurancePayers.Instructions")
    }

    static var empty = InsuranceViewPaymentState(memberId: "", groupId: "")
}

class InsurancePaymentViewModel: ObservableObject {
    @Published var state: InsuranceViewPaymentState = .empty
    @Published var insuranceProvidersLoadingState: ViewLoadingState = .loading
    @Published var insurancePayerLoadingError: String? = nil
    @Published var isInsurancePayerLoading: Bool = false
    @Published var insurancePayerPickerEntries: [CustomPickerEntry<InsurancePayer>] = []
    private var paymentMethod: PaymentMethod?
    private let paymentService: PaymentService

    // MARK: Lifecycle

    init(
        tenant: String = Current.configurationService.selectedAppConfiguration.tenant,
        paymentService: PaymentService = Current.dexcareSDK.paymentService
    ) {
        self.paymentService = paymentService
        loadInsuranceProviders(tenant: tenant)
    }

    // MARK: Validation

    func makePaymentMethod() -> PaymentMethod {
        .insuranceSelf(
            memberId: state.memberId,
            payorId: state.selectedInsurancePayer?.payerId ?? "",
            insuranceGroupNumber: state.groupId.isEmpty ? nil : state.groupId,
            payorName: state.selectedInsurancePayer?.name
        )
    }

    func updateState(paymentMethod: PaymentMethod?) {
        self.paymentMethod = paymentMethod
        switch paymentMethod {
        case let .insuranceSelf(memberId, payorId, insuranceGroupNumber, _):
            state = .init(
                memberId: memberId,
                groupId: insuranceGroupNumber ?? "",
                selectedInsurancePayer: findInsurancePayer(payorId, in: insurancePayerPickerEntries)
            )
            return
        default:
            return
        }
    }

    func validateStep() -> String? {
        RulesValidator.validate([
            { self.validateInsurancePayer(self.state.selectedInsurancePayer) },
            { self.validateMemberId(self.state.memberId) },
        ])
    }

    func validateMemberId(_ memberId: String) -> String? {
        memberId.isEmpty ? String(localized: "RegistrationStep.Field.MemberId.CannotBeEmptyMessage") : nil
    }

    func validateInsurancePayer(_ insurancePayer: InsurancePayer?) -> String? {
        insurancePayer == nil ? String(localized: "RegistrationStep.Field.InsurancePayer.CannotBeEmptyMessage") : nil
    }

    // MARK: Private

    private func findInsurancePayer(_ payorId: String, in insurancePayers: [CustomPickerEntry<InsurancePayer>]) -> InsurancePayer? {
        if payorId == "dexcare_test_zzz" {
            /// Search for the dexcare test insurance payor
            return insurancePayers.first { $0.item.name.starts(with: "zzz - ") }.map { $0.item }
        }
        return insurancePayers.first { $0.item.payerId == payorId }.map { $0.item }
    }

    private func loadInsuranceProviders(tenant: String) {
        Task { @MainActor in
            do {
                updateViewLoadingView(.loading)
                let insurancePayers = try await self.paymentService.getInsurancePayers(tenant: tenant)
                if insurancePayers.count == 0 {
                    updateViewLoadingView(.error, errorMessage: String(localized: "InsurancePayers.NoInsuranceProviders.ErrorMessage"))
                } else {
                    insurancePayerPickerEntries = insurancePayers.map { .init(title: $0.name, item: $0) }
                    updateViewLoadingView(.loaded)
                    self.updateState(paymentMethod: paymentMethod)
                }
            } catch {
                updateViewLoadingView(.error, errorMessage: String(localized: "InsurancePayers.FaileToLoadAPI"))
            }
        }
    }

    private func updateViewLoadingView(_ loadingState: ViewLoadingState, errorMessage: String? = nil) {
        insuranceProvidersLoadingState = loadingState
        isInsurancePayerLoading = loadingState == .loading
        insurancePayerLoadingError = errorMessage
    }
}
