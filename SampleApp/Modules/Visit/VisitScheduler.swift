//
//  VisitScheduler.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-17.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import os.log
import SwiftUI

/// Supported visit flow.
enum VisitSchedulerVisitType {
    /// Virtual Visit flow.
    case virtualVisit
    /// Provider Booking flow.
    case providerBooking
}

protocol VisitSchedulerType {
    var schedulerVisitType: VisitSchedulerVisitType { get }
    var paymentMethod: PaymentMethod? { get }
    var patientDemographics: PatientDemographics? { get }
    var provider: Provider? { get }
    var visitReason: String? { get }
    var providerVisitType: ProviderVisitType? { get }
    var logCategory: OSLog { get }

    func updatePatientDemographics(_ patientDemographics: PatientDemographics?)
    func updatePatientDemographics(personalInfoStepViewState: PersonalInfoStepViewState?)
    func updatePaymentStep(_ paymentMethod: PaymentMethod?)
    func updateReasonStep(visitReason: String?)
    func updateTestPersona(persona: VirtualVisitSamplePersona)
    func updateProvider(_ provider: Provider?)
    func updateVisitType(_ visitType: ProviderVisitType)
    func updateTimeSlot(_ timeSlot: TimeSlot)
    func reset()
    func scheduleProviderVisit(
        presentLoadingView: @escaping (Bool) -> Void,
        presentAlert: @escaping (_ alert: IdentifiableAlert) -> Void
    ) async throws -> ScheduledProviderVisit
    func startVirtualVisit(
        presentLoadingView: @escaping (Bool) -> Void,
        presentAlert: @escaping (_ alert: IdentifiableAlert) -> Void,
        onCompletion: @escaping (VisitCompletionReason) -> Void
    )
}

/// This class is used to consolidate the information needed for the `Virtual Visit` and `Provider Booking` flows
class VisitScheduler: VisitSchedulerType {
    // MARK: VisitSchedulerType Properties

    private(set) var patientDemographics: PatientDemographics?
    private(set) var paymentMethod: PaymentMethod?
    private(set) var personalInfoStepViewState: PersonalInfoStepViewState?
    private(set) var visitReason: String?
    private(set) var providerVisitType: ProviderVisitType?
    private(set) var provider: Provider?
    private(set) var timeSlot: TimeSlot?
    let schedulerVisitType: VisitSchedulerVisitType
    var logCategory: OSLog {
        switch schedulerVisitType {
        case .virtualVisit:
            .virtualVisit
        case .providerBooking:
            .providerBooking
        }
    }

    // MARK: Private Properties

    private let brand: String
    private let practiceId: String
    private let practiceRegion: VirtualPracticeRegion?
    private let logger: LoggerType
    private let patientService: PatientService
    private let practiceService: PracticeService
    private let providerService: ProviderService
    private let userDefaultsService: UserDefaultsServiceType
    private let virtualService: VirtualService

    // MARK: Lifecycle

    init(
        brand: String,
        practiceId: String,
        practiceRegion: VirtualPracticeRegion?,
        schedulerVisitType: VisitSchedulerVisitType,
        logger: LoggerType = Current.logger,
        patientService: PatientService = Current.dexcareSDK.patientService,
        practiceService: PracticeService = Current.dexcareSDK.practiceService,
        providerService: ProviderService = Current.dexcareSDK.providerService,
        userDefaultsService: UserDefaultsServiceType = Current.userDefaultsService,
        virtualService: VirtualService = Current.dexcareSDK.virtualService
    ) {
        self.brand = brand
        self.practiceId = practiceId
        self.practiceRegion = practiceRegion
        self.logger = logger
        self.patientService = patientService
        self.practiceService = practiceService
        self.providerService = providerService
        self.userDefaultsService = userDefaultsService
        self.virtualService = virtualService
        self.schedulerVisitType = schedulerVisitType
    }

    // MARK: Internal Methods

    /// Schedules a provider visit
    ///
    /// Before calling this method, you will need to provider the following information:
    ///   - Provider
    ///   - Visit Type
    ///   - Time Slot
    ///   - Visit Reason
    ///   - Patient Demographic
    ///   - Payment Method
    func scheduleProviderVisit(
        presentLoadingView: @escaping (Bool) -> Void,
        presentAlert: @escaping (_ alert: IdentifiableAlert) -> Void
    ) async throws -> ScheduledProviderVisit {
        guard let paymentMethod,
              let timeSlot,
              let patientDemographics,
              let visitReason,
              let firstDepartments = provider?.departments.first
        else {
            logger.log("Unable to call 'scheduleProviderVisit' as some mandatory information is missing.", level: .error, sender: .providerBooking)
            presentAlert(.error(message: String(localized: "VisitScheduler.AlertMessage.ScheduleProviderMandatoryFieldsMissing")))
            throw String(localized: "VisitScheduler.AlertMessage.ScheduleProviderMandatoryFieldsMissing")
        }

        let ehrSystemName = firstDepartments.ehrSystemName
        let providerVisitInformation = ProviderVisitInformation(
            visitReason: visitReason,
            patientDeclaration: .`self`,
            userEmail: patientDemographics.email,
            contactPhoneNumber: patientDemographics.mobilePhone ?? "",
            nationalProviderId: timeSlot.providerNationalId,
            visitTypeId: timeSlot.visitTypeId,
            ehrSystemName: ehrSystemName,
            actorRelationshipToPatient: nil // set nil when making a retail appointment "myself"
        )

        do {
            presentLoadingView(true)

            let patient = try await patientService.findOrCreatePatient(
                inEhrSystem: firstDepartments.ehrSystemName,
                patientDemographics: patientDemographics
            )

            let scheduledProviderVisit = try await withCheckedThrowingContinuation { continuation in
                self.providerService.scheduleProviderVisit(
                    paymentMethod: paymentMethod,
                    providerVisitInformation: providerVisitInformation,
                    timeSlot: timeSlot,
                    ehrSystemName: ehrSystemName,
                    patientDexCarePatient: patient,
                    actorDexCarePatient: nil,
                    success: continuation.resume(returning:),
                    failure: continuation.resume(throwing:)
                )
            }
            presentLoadingView(false)
            logger.log("Provider Booking Scheduled. Visit Id = '\(scheduledProviderVisit.visitId)'", level: .debug, sender: logCategory)
            return scheduledProviderVisit
        } catch {
            presentLoadingView(false)
            presentAlert(.error(error))
            throw error
        }
    }

    /// Creates and starts a virtual visit
    ///
    /// Before calling this method, you will need to provider the following information:
    ///   - Practice Region
    ///   - Visit Reason
    ///   - Patient Demographic
    ///   - Payment Method
    func startVirtualVisit(
        presentLoadingView: @escaping (Bool) -> Void,
        presentAlert: @escaping (_ alert: IdentifiableAlert) -> Void,
        onCompletion: @escaping (VisitCompletionReason) -> Void
    ) {
        guard let rootViewController = UIApplication.shared.firstKeyWindowRootViewController else {
            logger.log("Failed to find root view to launch virtual visit.", level: .error, sender: .virtualVisit)
            presentAlert(.error(message: String(localized: "VisitScheduler.AlertMessage.StartVirtualVisitMandatoryFieldsMissing")))
            onCompletion(.failed)
            return
        }
        guard let patientDemographics,
              let paymentMethod,
              let practiceRegion,
              let firstDepartments = practiceRegion.departments.first
        else {
            logger.log("Unable to call 'createVirtualVisit' as some mandatory information is missing.", level: .error, sender: .virtualVisit)
            presentAlert(.error(message: String(localized: "VisitScheduler.AlertMessage.StartVirtualVisitMandatoryFieldsMissing")))
            onCompletion(.failed)
            return
        }

        Task { @MainActor [weak self] in
            guard let self = self else { return }

            presentLoadingView(true)
            do {
                let virtualPractice = try await self.practiceService.getVirtualPractice(
                    practiceId: self.practiceId
                )
                let patient = try await self.patientService.findOrCreatePatient(
                    inEhrSystem: firstDepartments.ehrSystemName,
                    patientDemographics: patientDemographics
                )

                let visitId = try await withCheckedThrowingContinuation { continuation in
                    self.virtualService.createVirtualVisit(
                        presentingViewController: rootViewController,
                        dexcarePatient: patient,
                        virtualVisitDetails: VirtualVisitDetails(
                            acceptedTerms: true,
                            assignmentQualifiers: nil,
                            patientDeclaration: .self,
                            stateLicensure: practiceRegion.regionCode,
                            visitReason: self.visitReason ?? "",
                            visitTypeName: .virtual,
                            userEmail: patientDemographics.email,
                            contactPhoneNumber: patientDemographics.mobilePhone ?? "",
                            practiceId: virtualPractice.practiceId,
                            assessmentToolUsed: nil,
                            brand: self.brand,
                            interpreterLanguage: nil,
                            preTriageTags: nil,
                            urgency: nil,
                            actorRelationshipToPatient: nil,
                            additionalDetails: nil
                        ),
                        paymentMethod: paymentMethod,
                        actor: nil,
                        onCompletion: { [weak self] reason in
                            guard let self else { return }
                            presentLoadingView(false)
                            presentCompletionReason(reason, presentAlert: presentAlert) {
                                onCompletion(reason)
                            }
                            userDefaultsService.setLastVirtualVisitId(nil)
                            logVirtualVisitStats()
                            logger.log("Completed virtual visit. Reason = '\(reason)'", level: .verbose, sender: .virtualVisit)
                        },
                        success: continuation.resume(returning:),
                        failure: continuation.resume(throwing:)
                    )
                }
                userDefaultsService.setLastVirtualVisitId(visitId)
            } catch {
                presentLoadingView(false)
                presentAlert(.error(error))
                onCompletion(.failed)
            }
        }
    }

    // MARK: Internal Methods - Update

    /// Resets the visit scheduler class.
    /// This is mainly use for our test personas to ensure that when we go back and select a new
    /// option all the scheduler data is cleand up.
    func reset() {
        paymentMethod = nil
        patientDemographics = nil
        visitReason = nil
    }

    /// Updates the scheduler with the payment method step
    func updatePaymentStep(_ paymentMethod: PaymentMethod?) {
        self.paymentMethod = paymentMethod
    }

    /// Updates the scheduler with the patient selection step information
    func updatePatientDemographics(_ patientDemographics: PatientDemographics?) {
        self.patientDemographics = patientDemographics
    }

    /// Updates the scheduler with the patient personal information step information
    func updatePatientDemographics(personalInfoStepViewState: PersonalInfoStepViewState?) {
        patientDemographics = makePatientDemographics(personalInfoStepViewState: personalInfoStepViewState)
    }

    func updateProvider(_ provider: Provider?) {
        self.provider = provider
    }

    /// Updates the scheduler with the reason step information
    func updateReasonStep(visitReason: String?) {
        self.visitReason = visitReason
    }

    /// Updates the scheduler with the patient selection step test persona
    func updateTestPersona(persona: VirtualVisitSamplePersona) {
        populateStepsWithTestPersona(persona)
    }

    /// Updates the scheduler visit type
    func updateVisitType(_ visitType: ProviderVisitType) {
        providerVisitType = visitType
    }

    /// Updates the scheduler selected time slot
    func updateTimeSlot(_ timeSlot: TimeSlot) {
        self.timeSlot = timeSlot
    }

    // MARK: Private

    private func logVirtualVisitStats() {
        let stats = virtualService.getVideoCallStatistics()
        logger.log("Stats: \(String(describing: stats))", level: .debug, sender: .virtualVisit)
    }

    private func makeAddress(personalInfoStepViewState: PersonalInfoStepViewState) -> Address {
        Address(
            line1: personalInfoStepViewState.patientAddressLine1,
            line2: personalInfoStepViewState.patientAddressLine2,
            city: personalInfoStepViewState.patientCity,
            state: personalInfoStepViewState.patientState,
            postalCode: personalInfoStepViewState.patientZipCode
        )
    }

    private func makePatientDemographics(personalInfoStepViewState: PersonalInfoStepViewState?) -> PatientDemographics? {
        guard let personalInfoStepViewState,
              let patientBirthdate = personalInfoStepViewState.patientBirthdate,
              let patientGender = personalInfoStepViewState.patientGender else {
            return nil
        }

        let address = makeAddress(personalInfoStepViewState: personalInfoStepViewState)
        let name = makePatientName(personalInfoStepViewState: personalInfoStepViewState)
        return PatientDemographics(
            name: name,
            addresses: [address],
            birthdate: patientBirthdate,
            email: personalInfoStepViewState.patientEmail,
            gender: patientGender,
            ehrSystemName: patientDemographics?.ehrSystemName,
            last4SSN: personalInfoStepViewState.patientLastFourSSN,
            homePhone: patientDemographics?.homePhone,
            mobilePhone: personalInfoStepViewState.patientPhoneNumber,
            workPhone: patientDemographics?.workPhone
        )
    }

    private func makePatientName(personalInfoStepViewState: PersonalInfoStepViewState) -> HumanName {
        HumanName(
            family: personalInfoStepViewState.patientLastName,
            given: personalInfoStepViewState.patientFirstName,
            middle: nil,
            prefix: nil,
            suffix: nil,
            use: nil
        )
    }

    private func populateStepsWithTestPersona(_ testPersona: VirtualVisitSamplePersona?) {
        guard let testPersona = testPersona else { return }

        visitReason = testPersona.extraInfo.visitReason ?? ""
        patientDemographics = testPersona.patientDemographics

        switch testPersona.extraInfo.paymentInfo.paymentMethod {
        case .couponCode:
            paymentMethod = .couponCode(testPersona.extraInfo.paymentInfo.couponCode ?? "")
        case .creditCard:
            paymentMethod = .creditCard(stripeToken: "")
        case .insuranceSelf:
            paymentMethod = .insuranceSelf(
                memberId: testPersona.extraInfo.paymentInfo.insuranceMemberId ?? "",
                payorId: testPersona.extraInfo.paymentInfo.insurancePayerId ?? "",
                insuranceGroupNumber: nil,
                payorName: nil
            )
        }
    }

    private func presentCompletionReason(
        _ reason: VisitCompletionReason,
        presentAlert: @escaping (IdentifiableAlert) -> Void,
        onCompletion: @escaping () -> Void
    ) {
        switch reason {
        case .completed,
             .phoneVisit,
             .left:
            return onCompletion()
        case .canceled,
             .alreadyInConference,
             .conferenceFull,
             .conferenceInactive,
             .conferenceNonExistent,
             .micAndCamNotConnected,
             .networkIssues,
             .exceededReconnectAttempt,
             .joinedElsewhere,
             .staffDeclined,
             .failed,
             .waitOffline:
            // We need to dismiss the virtual visit session/screen before showing the alert.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                presentAlert(.info(
                    title: reason.alertTitle,
                    message: reason.alertMessage,
                    onOk: onCompletion
                ))
            }
        }
    }
}

// MARK: Preview

extension VisitScheduler {
    static var previewMock: VisitScheduler {
        VisitScheduler(
            brand: "someBrand",
            practiceId: "1234",
            practiceRegion: VirtualPracticeRegion(
                practiceRegionId: "1",
                displayName: "Washington",
                regionCode: "WA",
                active: true,
                busy: false,
                busyMessage: "",
                visitPrice: 49.99,
                availability: [],
                pediatricsAgeRange: nil,
                departments: []
            ),
            schedulerVisitType: .virtualVisit
        )
    }
}
