//
//  PatientSelectionViewModel.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-25.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import SwiftUI

// MARK: ViewModel

class PatientSelectionStepViewModel: ObservableObject {
    // MARK: Properties

    @Published var alertPresenter: AlertPresenter = .init()
    @Published private(set) var myselfPatientDemographics: PatientDemographics?
    @Published private(set) var isPatientInformationLoading: Bool = true
    private(set) var patientInformationLoadingError: String?
    @Published private(set) var testPersonas: [VirtualVisitSamplePersona]

    private let visitScheduler: VisitSchedulerType
    private let navigationState: NavigationState
    private let patientService: PatientService

    // MARK: Lifecycle

    init(
        visitScheduler: VisitSchedulerType,
        navigationState: NavigationState = Current.navigationState,
        patientService: PatientService = Current.dexcareSDK.patientService,
        sampleData: [VirtualVisitSamplePersona] = Current.configurationService.sampleData.virtualVisitPatients
    ) {
        self.visitScheduler = visitScheduler
        self.navigationState = navigationState
        self.patientService = patientService
        testPersonas = sampleData

        loadPatientInformation()
    }

    func onMyselfButtonTapped() {
        resetVisitScheduler()
        visitScheduler.updatePatientDemographics(myselfPatientDemographics)
        navigationState.push(.reasonStep(visitScheduler: visitScheduler))
    }

    func onSomeoneElseButtonTapped() {
        alertPresenter.present(.info(
            title: String(localized: "Alert.NotImplemented.Title"),
            message: String(localized: "Alert.NotImplemented.Message")
        ))
    }

    func onPersonaButtonTapped(persona: VirtualVisitSamplePersona) {
        resetVisitScheduler()
        visitScheduler.updateTestPersona(persona: persona)
        navigationState.push(.reasonStep(visitScheduler: visitScheduler))
    }

    // MARK: Private

    private func resetVisitScheduler() {
        visitScheduler.reset()
    }

    private func isLoading(_ isLoading: Bool, errorMessage: String? = nil) {
        isPatientInformationLoading = isLoading
        patientInformationLoadingError = errorMessage
    }

    private func loadPatientInformation() {
        isLoading(true)
        Task { @MainActor in
            do {
                let patient = try await patientService.getPatient()
                self.myselfPatientDemographics = patient.demographicsLinks.first
                isLoading(false)
            } catch {
                isLoading(false, errorMessage: String(localized: "Patient.FailedToLoadPatient.Message"))
                alertPresenter.present(.error(error))
            }
        }
    }
}
