//  Copyright © 2020 DexCare. All rights reserved.

import DexcareiOSSDK
import Foundation
import PromiseKit

class RetailServiceHelper {
    var myselfInformation: PersonInformation?
    var addressInformation: PersonDemographicAddress?
    var dependentInformation: PersonInformation?
    var dependentAddressInformation: PersonDemographicAddress?
    var dependentEmail: String?

    var reasonForVisit: String?
    var timeslot: TimeSlot?
    var ehrSystemName: String?
    var userEmail: String?
    var phoneNumber: String?
    var currentDexcarePatient: DexcarePatient?
    var relationshipToPatient: RelationshipToPatient?
    var isDependentBooking: Bool = false

    func bookVisit() -> Promise<Void> {
        guard let reasonForVisit = reasonForVisit else { return Promise(error: "Missing reason for visit") }
        guard let timeslot = timeslot else { return Promise(error: "Missing timeslot") }
        guard let ehrSystemName = ehrSystemName else { return Promise(error: "Missing ehrSystemName") }

        var combindUserEmail = ""
        var combinedPhoneNumber = ""
        var patientDeclaration: PatientDeclaration = .`self`

        if isDependentBooking {
            guard let email = dependentEmail else { return Promise(error: "Missing userEmail") }
            guard let dependentPhone = phoneNumber ?? dependentAddressInformation?.phoneNumber else { return Promise(error: "Missing phoneNumber") }

            combinedPhoneNumber = dependentPhone
            combindUserEmail = email
            patientDeclaration = .other

        } else {
            guard let email = userEmail else { return Promise(error: "Missing userEmail") }
            guard let patientPhoneNumber = phoneNumber ?? addressInformation?.phoneNumber else { return Promise(error: "Missing phoneNumber") }

            combinedPhoneNumber = patientPhoneNumber
            combindUserEmail = email
        }

        let visitInformation = RetailVisitInformation(
            visitReason: reasonForVisit,
            patientDeclaration: patientDeclaration,
            userEmail: combindUserEmail,
            contactPhoneNumber: combinedPhoneNumber,
            actorRelationshipToPatient: relationshipToPatient // set nil when making a retail appointment "myself"
        )

        let dexcareSDK = AppServices.shared.dexcareSDK

        return firstly {
            try updatePatientDemographics()
        }.then { patient in
            try self.updateDependentPatientDemographics().map { (patient, $0) }
        }.then { patient, dependentPatient in
            Promise { seal in
                dexcareSDK.retailService.scheduleRetailAppointment(
                    paymentMethod: .`self`,
                    visitInformation: visitInformation,
                    timeslot: timeslot,
                    ehrSystemName: ehrSystemName,
                    patientDexCarePatient: self.isDependentBooking ? dependentPatient! : patient,
                    actorDexCarePatient: self.isDependentBooking ? patient : nil,
                    success: { _ in
                        // save this
                        seal.fulfill(())
                    }
                ) { failedReason in
                    print("Failed to book a retail visit: \(failedReason)")
                    seal.reject(failedReason)
                }
            }
        }
    }

    func bookProviderVisit() -> Promise<Void> {
        guard let reasonForVisit = reasonForVisit else { return Promise(error: "Missing reason for visit") }
        guard let timeslot = timeslot else { return Promise(error: "Missing timeslot") }
        guard let ehrSystemName = ehrSystemName else { return Promise(error: "Missing ehrSystemName") }

        var combindUserEmail = ""
        var combinedPhoneNumber = ""
        var patientDeclaration: PatientDeclaration = .`self`

        if isDependentBooking {
            guard let email = dependentEmail else { return Promise(error: "Missing userEmail") }
            guard let dependentPhone = phoneNumber ?? dependentAddressInformation?.phoneNumber else { return Promise(error: "Missing phoneNumber") }

            combinedPhoneNumber = dependentPhone
            combindUserEmail = email
            patientDeclaration = .other

        } else {
            guard let email = userEmail else { return Promise(error: "Missing userEmail") }
            guard let patientPhoneNumber = phoneNumber ?? addressInformation?.phoneNumber else { return Promise(error: "Missing phoneNumber") }

            combinedPhoneNumber = patientPhoneNumber
            combindUserEmail = email
        }

        let providerVisitInformation = ProviderVisitInformation(
            visitReason: "Test visit reason from integrated DexcareSDK iOS Tests - ProviderBooking",
            patientDeclaration: .self,
            userEmail: combindUserEmail,
            contactPhoneNumber: "(204)555-2322",
            nationalProviderId: timeslot.providerNationalId,
            visitTypeId: timeslot.visitTypeId,
            ehrSystemName: ehrSystemName,
            actorRelationshipToPatient: relationshipToPatient // set nil when making a retail appointment "myself"
        )

        let dexcareSDK = AppServices.shared.dexcareSDK

        return firstly {
            try updatePatientDemographics()
        }.then { patient in
            try self.updateDependentPatientDemographics().map { (patient, $0) }
        }.then { patient, dependentPatient in
            Promise { seal in

                dexcareSDK.providerService.scheduleProviderVisit(
                    paymentMethod: .self,
                    providerVisitInformation: providerVisitInformation,
                    timeSlot: timeslot,
                    ehrSystemName: ehrSystemName,
                    patientDexCarePatient: self.isDependentBooking ? dependentPatient! : patient,
                    actorDexCarePatient: self.isDependentBooking ? patient : nil,
                    success: { _ in
                        seal.fulfill(())
                    },
                    failure: { error in
                        seal.reject(error)
                    }
                )
            }
        }
    }

    func updatePatientDemographics() throws -> Promise<DexcarePatient> {
        guard let ehrSystem = ehrSystemName else {
            throw "Missing ehrSystemName"
        }
        guard let myselfInformation = myselfInformation else {
            throw "Missing myselfInformation"
        }
        guard let addressInformation = addressInformation else {
            throw "Missing myselfInformation"
        }

        let patientDemographics = try buildMyselfDemographics(email: userEmail, myselfInformation: myselfInformation, myselfAddress: addressInformation)
        let dexcareSDK = AppServices.shared.dexcareSDK

        return Promise { seal in
            dexcareSDK.patientService.findOrCreatePatient(
                inEhrSystem: ehrSystem,
                patientDemographics: patientDemographics,
                success: { [weak self] patient in
                    self?.currentDexcarePatient = patient
                    seal.fulfill(patient)
                }, failure: { error in
                    print("error saving patient: \(error)")
                    seal.reject(error)
                }
            )
        }
    }

    func updateDependentPatientDemographics() throws -> Promise<DexcarePatient?> {
        if !isDependentBooking {
            return Promise.value(nil)
        }
        guard let ehrSystem = ehrSystemName else {
            throw "Missing ehrSystemName"
        }
        guard let myselfInformation = dependentInformation else {
            throw "Missing myselfInformation"
        }
        guard let addressInformation = dependentAddressInformation else {
            throw "Missing myselfInformation"
        }

        let patientDemographics = try buildMyselfDemographics(email: dependentEmail, myselfInformation: myselfInformation, myselfAddress: addressInformation)
        let dexcareSDK = AppServices.shared.dexcareSDK

        return Promise { seal in
            dexcareSDK.patientService.findOrCreateDependentPatient(
                inEhrSystem: ehrSystem,
                dependentPatientDemographics: patientDemographics,
                success: { [weak self] patient in
                    seal.fulfill(patient)
                }, failure: { error in
                    print("error saving patient: \(error)")
                    seal.reject(error)
                }
            )
        }
    }

    private func buildMyselfDemographics(email: String?, myselfInformation: PersonInformation, myselfAddress: PersonDemographicAddress) throws -> PatientDemographics {
        guard let email = email else {
            throw "Missing actor email from logged in account"
        }

        guard let firstName = myselfInformation.firstName else {
            throw "Missing actor first name from demographics form"
        }
        guard let lastName = myselfInformation.lastName else {
            throw "Missing actor last name from demographics form"
        }
        guard let birthDate = myselfInformation.birthDate else {
            throw "Missing actor birth date from demographics form"
        }
        guard let gender = myselfInformation.gender else {
            throw "Missing actor gender from demographics form"
        }
        let addressLine1 = myselfAddress.address.line1
        guard !addressLine1.isEmpty else {
            throw "Missing actor street address line 1 from demographics form"
        }
        let city = myselfAddress.address.city
        guard !city.isEmpty else {
            throw "Missing actor city from demographics form"
        }

        let state = myselfAddress.address.state
        guard !state.isEmpty else {
            throw "Missing actor state from demographics form"
        }

        let lastFourSSN: String
        lastFourSSN = myselfInformation.lastFourSSN.value
        guard lastFourSSN.count == myselfInformation.lastFourSSN.maxLength else {
            throw "Missing actor last 4 social security number from demographics form"
        }

        let postalCode = myselfAddress.address.postalCode
        guard !postalCode.isEmpty else {
            throw "Missing actor postal code from demographics form"
        }
        let phoneNumber = myselfAddress.phoneNumber
        guard !phoneNumber.isEmpty else {
            throw "Missing actor phone number from demographics form"
        }
        let addressLine2 = myselfAddress.address.line2

        let name = HumanName(
            family: lastName,
            given: firstName,
            middle: nil,
            prefix: nil,
            suffix: nil,
            use: nil
        )
        let address = Address(
            line1: addressLine1,
            line2: addressLine2,
            city: city,
            state: state,
            postalCode: postalCode
        )

        let demographics = PatientDemographics(
            name: name,
            addresses: [address],
            birthDate: birthDate,
            email: email,
            gender: gender,
            ehrSystemName: nil, // EHR System will get filled in by SDK when VisitState/EHRSystem is passed in
            last4SSN: lastFourSSN,
            homePhone: phoneNumber,
            mobilePhone: nil, // SDK requires a home phone number, all other phone numbers are optional
            workPhone: nil
        )
        return demographics
    }
}
