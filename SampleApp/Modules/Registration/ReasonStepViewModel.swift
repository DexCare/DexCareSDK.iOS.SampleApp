//
//  ReasonStepViewModel.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-18.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation
import SwiftUI

struct ReasonStepViewState {
    var visitReason: String = ""
}

class ReasonStepViewModel: ObservableObject {
    // MARK: Properties

    @Published var alertPresenter: AlertPresenter = .init()
    @Published var state: ReasonStepViewState
    private let visitScheduler: VisitSchedulerType
    private let navigationState: NavigationState

    // MARK: Lifecycle

    init(
        visitScheduler: VisitSchedulerType,
        navigationState: NavigationState = Current.navigationState
    ) {
        self.visitScheduler = visitScheduler
        state = Self.makeState(visitReason: visitScheduler.visitReason)
        self.navigationState = navigationState
    }

    // MARK: Internal Methods

    func onContinueButtonTapped() {
        if let validationMessage = validateStep() {
            alertPresenter.present(.error(message: validationMessage))
            return
        }
        visitScheduler.updateReasonStep(visitReason: state.visitReason)
        navigationState.push(.personalInfoStep(visitScheduler: visitScheduler))
    }

    func validateReason(_ reason: String) -> String? {
        reason.isEmpty ? String(localized: "RegistrationStep.Field.Reason.CannotBeEmptyMessage") : nil
    }

    // MARK: Private Methods

    private static func makeState(visitReason: String?) -> ReasonStepViewState {
        ReasonStepViewState(visitReason: visitReason ?? "")
    }

    private func validateStep() -> String? {
        validateReason(state.visitReason)
    }
}
