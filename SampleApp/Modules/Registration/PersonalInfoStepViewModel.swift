//
//  PersonalInfoStepViewModel.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-18.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import SwiftUI

// MARK: State

struct PersonalInfoStepViewState {
    // MARK: Properties

    var patientFirstName: String
    var patientLastName: String
    var patientEmail: String
    var patientBirthdate: Date? {
        didSet {
            patientBirthdateDisplayString = patientBirthdate?.birthdateString() ?? ""
        }
    }

    var patientBirthdateDisplayString: String
    var patientGender: Gender? {
        didSet {
            patientGenderDisplayString = patientGender?.demographicStringValue ?? ""
        }
    }

    var patientGenderDisplayString: String
    var patientLastFourSSN: String
    var patientPhoneNumber: String
    var patientAddressLine1: String
    var patientAddressLine2: String
    var patientCity: String
    var patientState: String
    var patientZipCode: String

    // MARK: Lifecycle

    init(
        patientFirstName: String = "",
        patientLastName: String = "",
        patientEmail: String = "",
        patientBirthdate: Date? = nil,
        patientGender: Gender? = nil,
        patientLastFourSSN: String = "",
        patientPhoneNumber: String = "",
        patientAddressLine1: String = "",
        patientAddressLine2: String = "",
        patientCity: String = "",
        patientState: String = "",
        patientZipCode: String = ""
    ) {
        self.patientFirstName = patientFirstName
        self.patientLastName = patientLastName
        self.patientEmail = patientEmail
        self.patientBirthdate = patientBirthdate
        patientBirthdateDisplayString = patientBirthdate?.birthdateString() ?? ""
        self.patientGender = patientGender
        patientGenderDisplayString = patientGender?.demographicStringValue ?? ""
        self.patientLastFourSSN = patientLastFourSSN
        self.patientPhoneNumber = patientPhoneNumber
        self.patientAddressLine1 = patientAddressLine1
        self.patientAddressLine2 = patientAddressLine2
        self.patientCity = patientCity
        self.patientState = patientState
        self.patientZipCode = patientZipCode
    }
}

// MARK: ViewModel

class PersonalInfoStepViewModel: ObservableObject {
    // MARK: Properties

    @Published var alertPresenter: AlertPresenter = .init()
    @Published var state: PersonalInfoStepViewState = .init()
    private let visitScheduler: VisitSchedulerType
    private let navigationState: NavigationState

    // MARK: Lifecycle

    init(
        visitScheduler: VisitSchedulerType,
        navigationState: NavigationState = Current.navigationState
    ) {
        state = Self.makePersonalInfoStepViewState(patientDemographics: visitScheduler.patientDemographics)
        self.visitScheduler = visitScheduler
        self.navigationState = navigationState
    }

    // MARK: Internal Methods

    func onContinueButtonTapped() {
        if let validationMessage = validateStep() {
            alertPresenter.present(.error(message: validationMessage))
            return
        }
        saveState()
        navigationState.push(.paymentStep(visitScheduler: visitScheduler))
    }

    func saveState() {
        visitScheduler.updatePatientDemographics(personalInfoStepViewState: state)
    }

    // MARK: Validations

    /// Ensures that all the mandatory information for this step has been entered and validated
    ///
    /// - Returns: Returns an error message if something is missing or invalid
    func validateStep() -> String? {
        RulesValidator.validate([
            { self.validateFirstName(self.state.patientFirstName) },
            { self.validateLastName(self.state.patientLastName) },
            { self.validateEmailAddress(self.state.patientEmail) },
            { self.validateBirthdate(self.state.patientBirthdate) },
            { self.validateGender(self.state.patientGender) },
            { self.validatePhoneNumber(self.state.patientPhoneNumber) },
            { self.validateZipCode(self.state.patientZipCode) },
        ])
    }

    func validateFirstName(_ firstName: String) -> String? {
        firstName.isEmpty ? String(localized: "RegistrationStep.Field.FirstName.CannotBeEmptyMessage") : nil
    }

    func validateLastName(_ lastName: String) -> String? {
        lastName.isEmpty ? String(localized: "RegistrationStep.Field.LastName.CannotBeEmptyMessage") : nil
    }

    func validateEmailAddress(_ email: String) -> String? {
        email.isValidEmail() ? nil : String(localized: "RegistrationStep.Field.Email.InvalidFormatMessage")
    }

    func validateGender(_ gender: Gender?) -> String? {
        gender == nil ? String(localized: "RegistrationStep.Field.Gender.CannotBeEmptyMessage") : nil
    }

    func validateBirthdate(_ birthdate: Date?) -> String? {
        birthdate == nil ? String(localized: "RegistrationStep.Field.Birthday.CannotBeEmptyMessage") : nil
    }

    func validatePhoneNumber(_ phoneNumber: String) -> String? {
        phoneNumber.isValidPhoneNumber() ? nil : String(localized: "RegistrationStep.Field.MobilePhoneNumber.InvalidFormatMessage")
    }

    func validateZipCode(_ zipCode: String) -> String? {
        zipCode.isValidZipCode() ? nil : String(localized: "RegistrationStep.Field.ZipCode.InvalidFormatMessage")
    }

    private static func makePersonalInfoStepViewState(patientDemographics: PatientDemographics?) -> PersonalInfoStepViewState {
        PersonalInfoStepViewState(
            patientFirstName: patientDemographics?.name.given ?? "",
            patientLastName: patientDemographics?.name.family ?? "",
            patientEmail: patientDemographics?.email ?? "",
            patientBirthdate: patientDemographics?.birthdate,
            patientGender: patientDemographics?.gender,
            patientLastFourSSN: patientDemographics?.last4SSN ?? "",
            patientPhoneNumber: patientDemographics?.mobilePhone ?? "",
            patientAddressLine1: patientDemographics?.addresses.first?.line1 ?? "",
            patientAddressLine2: patientDemographics?.addresses.first?.line2 ?? "",
            patientCity: patientDemographics?.addresses.first?.city ?? "",
            patientState: patientDemographics?.addresses.first?.state ?? "",
            patientZipCode: patientDemographics?.addresses.first?.postalCode ?? ""
        )
    }
}
