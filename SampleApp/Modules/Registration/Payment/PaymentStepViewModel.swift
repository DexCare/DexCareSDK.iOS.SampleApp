//
//  PaymentStepViewModel.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-18.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import SwiftUI

struct PaymentStepViewState {
    var paymentMethodDisplayString: String
    var paymentMethod: SupportedPaymentMethod? {
        didSet {
            paymentMethodDisplayString = paymentMethod?.localizedTitle ?? String(localized: "RegistrationStep.Field.PaymentMethod.Instructions")
        }
    }

    init(paymentMethod: SupportedPaymentMethod?) {
        self.paymentMethod = paymentMethod
        paymentMethodDisplayString = paymentMethod?.localizedTitle ?? String(localized: "RegistrationStep.Field.PaymentMethod.Instructions")
    }

    static var empty: PaymentStepViewState { PaymentStepViewState(paymentMethod: nil) }
}

class PaymentStepViewModel: ObservableObject {
    // MARK: Properties

    @Published var alertPresenter: AlertPresenter = .init()
    @Published var isLoadingViewPresented: Bool = false
    @Published var state: PaymentStepViewState
    private let visitScheduler: VisitSchedulerType
    private let navigationState: NavigationState
    private(set) var buttonTitle: String
    private(set) var couponCodeViewModel: CouponCodePaymentViewModel = .init()
    private(set) var insuranceViewModel: InsurancePaymentViewModel = .init()

    // MARK: Lifecycle

    init(
        visitScheduler: VisitSchedulerType,
        navigationState: NavigationState = Current.navigationState
    ) {
        state = PaymentStepViewState(paymentMethod: nil)
        self.visitScheduler = visitScheduler
        self.navigationState = navigationState
        buttonTitle = Self.makeButtonTitle(for: visitScheduler.schedulerVisitType)
        couponCodeViewModel.presentAlert = presentAlert
        state = makeState(paymentMethod: visitScheduler.paymentMethod)
    }

    // MARK: Internal Methods

    func paymentEntries() -> [CustomPickerEntry<SupportedPaymentMethod>] {
        [
            CustomPickerEntry(
                title: SupportedPaymentMethod.insuranceSelf.localizedTitle,
                item: SupportedPaymentMethod.insuranceSelf
            ),
            CustomPickerEntry(
                title: SupportedPaymentMethod.couponCode.localizedTitle,
                item: SupportedPaymentMethod.couponCode
            ),
        ]
    }

    func onMainButtonTapped() {
        if let validationMessage = validateStep() {
            alertPresenter.present(.error(message: validationMessage))
            return
        }

        visitScheduler.updatePaymentStep(makePaymentMethod())

        switch visitScheduler.schedulerVisitType {
        case .providerBooking:
            Task { @MainActor in
                do {
                    let scheduledProviderVisit = try await visitScheduler.scheduleProviderVisit(
                        presentLoadingView: { [weak self] present in self?.presentLoadingView(present) },
                        presentAlert: { [weak self] alert in self?.alertPresenter.present(alert) }
                    )
                    alertPresenter.present(.info(
                        title: String(localized: "VisitScheduler.AlertTitle.Success"),
                        message: String(format: String(localized: "VisitScheduler.AlertMessage.Success"), scheduledProviderVisit.visitId),
                        onOk: { [weak self] in
                            self?.navigationState.popToRoot()
                        }
                    ))
                } catch {
                    // All error presentation are handled by `scheduleProviderVisit()`
                }
            }
            return
        case .virtualVisit:
            visitScheduler.startVirtualVisit(
                presentLoadingView: { [weak self] present in self?.presentLoadingView(present) },
                presentAlert: { [weak self] alert in self?.alertPresenter.present(alert) },
                onCompletion: { [weak self] reason in
                    switch reason {
                    case .completed, .staffDeclined, .phoneVisit, .waitOffline:
                        self?.navigationState.popToRoot()
                    case .canceled, .left, .alreadyInConference, .conferenceFull, .conferenceInactive, .conferenceNonExistent, .micAndCamNotConnected, .networkIssues, .exceededReconnectAttempt, .joinedElsewhere, .failed:
                        break
                    }
                }
            )
        }
    }

    func validateStep() -> String? {
        switch state.paymentMethod {
        case .couponCode:
            return couponCodeViewModel.validateStep()
        case .insuranceSelf:
            return insuranceViewModel.validateStep()
        case .none:
            return nil
        }
    }

    // MARK: Private

    private func makeState(paymentMethod: PaymentMethod?) -> PaymentStepViewState {
        guard let paymentMethod else {
            return .empty
        }

        switch paymentMethod {
        case .couponCode:
            couponCodeViewModel.updateState(paymentMethod: paymentMethod)
            return PaymentStepViewState(paymentMethod: .couponCode)
        case .creditCard:
            return .empty
        case .insuranceSelf:
            insuranceViewModel.updateState(paymentMethod: paymentMethod)
            return PaymentStepViewState(paymentMethod: .insuranceSelf)
        default:
            return .empty
        }
    }

    private func makePaymentMethod() -> PaymentMethod? {
        switch state.paymentMethod {
        case .couponCode:
            return couponCodeViewModel.makePaymentMethod()
        case .insuranceSelf:
            return insuranceViewModel.makePaymentMethod()
        case .none:
            return nil
        }
    }

    private static func makeButtonTitle(for schedulerVisitType: VisitSchedulerVisitType) -> String {
        switch schedulerVisitType {
        case .providerBooking:
            String(localized: "RegistrationStep.Button.ScheduleProviderBooking")
        case .virtualVisit:
            String(localized: "RegistrationStep.Button.CreateVirtualVisit")
        }
    }

    private func presentAlert(_ alert: IdentifiableAlert) {
        alertPresenter.present(alert)
    }

    private func presentLoadingView(_ present: Bool) {
        withTransaction(.disabledAnimationTransaction) {
            self.isLoadingViewPresented = present
        }
    }
}
