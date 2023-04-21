//  Copyright © 2020 DexCare. All rights reserved.

import DexcareiOSSDK
import Foundation

class RetailServiceHelper {
    var myselfInformation: PersonInformation?
    var addressInformation: PersonDemographicAddress?
    var dependentInformation: PersonInformation?
    var dependentAddressInformation: PersonDemographicAddress?
    var dependentEmail: String?

    var reasonForVisit: String?
    var timeSlot: TimeSlot?
    var ehrSystemName: String?
    var userEmail: String?
    var phoneNumber: String?
    var currentDexcarePatient: DexcarePatient?
    var relationshipToPatient: RelationshipToPatient?
    var isDependentBooking: Bool = false

    func bookVisit() async throws {
        guard let reasonForVisit = reasonForVisit else { throw "Missing reason for visit" }
        guard let timeSlot = timeSlot else { throw "Missing time slot" }
        guard let ehrSystemName = ehrSystemName else { throw "Missing ehrSystemName" }

        let combinedUserEmail: String
        let combinedPhoneNumber: String
        let patientDeclaration: PatientDeclaration

        if isDependentBooking {
            guard let email = dependentEmail else { throw "Missing userEmail" }
            guard let dependentPhone = phoneNumber ?? dependentAddressInformation?.phoneNumber else { throw "Missing phoneNumber" }

            combinedPhoneNumber = dependentPhone
            combinedUserEmail = email
            patientDeclaration = .other

        } else {
            guard let email = userEmail else { throw "Missing userEmail" }
            guard let patientPhoneNumber = phoneNumber ?? addressInformation?.phoneNumber else { throw "Missing phoneNumber" }

            combinedPhoneNumber = patientPhoneNumber
            combinedUserEmail = email
            patientDeclaration = .self
        }

        let visitInformation = RetailVisitInformation(
            visitReason: reasonForVisit,
            patientDeclaration: patientDeclaration,
            userEmail: combinedUserEmail,
            contactPhoneNumber: combinedPhoneNumber,
            actorRelationshipToPatient: relationshipToPatient // set nil when making a retail appointment "myself"
        )

        let dexcareSDK = AppServices.shared.dexcareSDK

        let patient = try await updatePatientDemographics()
        let dependentPatient = try await updateDependentPatientDemographics()
        _ = try await dexcareSDK.retailService.scheduleRetailAppointment(
            paymentMethod: .self,
            visitInformation: visitInformation,
            timeslot: timeSlot,
            ehrSystemName: ehrSystemName,
            patientDexCarePatient: isDependentBooking ? dependentPatient! : patient,
            actorDexCarePatient: isDependentBooking ? patient : nil)
    }

    func bookProviderVisit() async throws {
        guard let reasonForVisit = reasonForVisit else { throw "Missing reason for visit" }
        guard let timeSlot = timeSlot else { throw "Missing time slot" }
        guard let ehrSystemName = ehrSystemName else { throw "Missing ehrSystemName" }

        let combinedUserEmail: String
        let combinedPhoneNumber: String
        let patientDeclaration: PatientDeclaration

        if isDependentBooking {
            guard let email = dependentEmail else { throw "Missing userEmail" }
            guard let dependentPhone = phoneNumber ?? dependentAddressInformation?.phoneNumber else { throw "Missing phoneNumber" }

            combinedPhoneNumber = dependentPhone
            combinedUserEmail = email
            patientDeclaration = .other

        } else {
            guard let email = userEmail else { throw "Missing userEmail" }
            guard let patientPhoneNumber = phoneNumber ?? addressInformation?.phoneNumber else { throw "Missing phoneNumber" }

            combinedPhoneNumber = patientPhoneNumber
            combinedUserEmail = email
            patientDeclaration = .self
        }

        let providerVisitInformation = ProviderVisitInformation(
            visitReason: reasonForVisit,
            patientDeclaration: patientDeclaration,
            userEmail: combinedUserEmail,
            contactPhoneNumber: combinedPhoneNumber,
            nationalProviderId: timeSlot.providerNationalId,
            visitTypeId: timeSlot.visitTypeId,
            ehrSystemName: ehrSystemName,
            actorRelationshipToPatient: relationshipToPatient // set nil when making a retail appointment "myself"
        )

        let dexcareSDK = AppServices.shared.dexcareSDK

        let patient = try await updatePatientDemographics()
        let dependentPatient = try await self.updateDependentPatientDemographics()
        _ = try await dexcareSDK.providerService.scheduleProviderVisit(
            paymentMethod: .self,
            providerVisitInformation: providerVisitInformation,
            timeSlot: timeSlot,
            ehrSystemName: ehrSystemName,
            patientDexCarePatient: self.isDependentBooking ? dependentPatient! : patient,
            actorDexCarePatient: self.isDependentBooking ? patient : nil)
    }

    func updatePatientDemographics() async throws -> DexcarePatient {
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

        let newPatient = try await dexcareSDK.patientService.findOrCreatePatient(inEhrSystem: ehrSystem, patientDemographics: patientDemographics)
        currentDexcarePatient = newPatient
        return newPatient
    }

    func updateDependentPatientDemographics() async throws -> DexcarePatient? {
        if !isDependentBooking {
            return nil
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

        return try await dexcareSDK.patientService.findOrCreateDependentPatient(
                inEhrSystem: ehrSystem,
                dependentPatientDemographics: patientDemographics)
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
