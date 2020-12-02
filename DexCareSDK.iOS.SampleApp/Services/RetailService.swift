//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import DexcareSDK
import PromiseKit

class RetailServiceHelper {
    var currentPatient: DexcarePatient?
    
    var myselfInformation: PersonInformation?
    var addressInformation: PersonDemographicAddress?
    
    var reasonForVisit: String?
    var timeslot: TimeSlot?
    var ehrSystemName: String?
    var userEmail: String?
    var phoneNumber: String?
    var currentDexcarePatient: DexcarePatient?
    
    func bookVisit() -> Promise<Void> {
        guard let reasonForVisit = reasonForVisit else { return Promise(error: "Missing reason for visit") }
        guard let timeslot = timeslot else { return Promise(error: "Missing timeslot") }
        guard let userEmail = userEmail else { return Promise(error: "Missing userEmail") }
        guard let phoneNumber = phoneNumber ?? addressInformation?.phoneNumber else { return Promise(error: "Missing phoneNumber") }

        let visitInformation = RetailVisitInformation(
            visitReason: reasonForVisit,
            patientDeclaration: .`self`,
            userEmail: userEmail,
            contactPhoneNumber: phoneNumber
        )
           
        let dexcareSDK = AppServices.shared.dexcareSDK

        return firstly {
            try updatePatientDemographics()
        }.then {
            return Promise { seal in
                dexcareSDK.appointmentService.scheduleRetailAppointment(
                    paymentMethod: .`self`,
                    visitInformation: visitInformation,
                    timeslot: timeslot,
                    success: {
                        seal.fulfill(())
                    }) { failedReason in
                        print("Failed to book a retail visit: \(failedReason)")
                        seal.reject(failedReason)
                    }
            }
        }
    }
    
    
    func updatePatientDemographics() throws -> Promise<Void>{
        
        guard let ehrSystem = ehrSystemName else {
            throw "Missing ehrSystemName"
        }
        guard let myselfInformation = myselfInformation else {
            throw "Missing myselfInformation"
        }
        guard let addressInformation = addressInformation else {
            throw "Missing myselfInformation"
        }
        
        let patientDemographics = try buildMyselfDemographics(myselfInformation: myselfInformation, myselfAddress: addressInformation)
        let dexcareSDK = AppServices.shared.dexcareSDK
        
        return Promise { seal in
            dexcareSDK.patientService.createPatient(
                inEhrSystem: ehrSystem,
                patientDemographics: patientDemographics,
                success: { [weak self] patient in
                    self?.currentDexcarePatient = patient
                    seal.fulfill(())
                }, failure: { error in
                    print("error saving patient: \(error)")
                    seal.reject(error)
            })
        }
    }
    
    private func buildMyselfDemographics(myselfInformation: PersonInformation, myselfAddress: PersonDemographicAddress) throws -> PatientDemographics {
        
        guard let email = userEmail else {
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
            ssn: lastFourSSN,
            homePhone: phoneNumber,
            mobilePhone: nil, // SDK requires a home phone number, all other phone numbers are optional
            workPhone: nil,
            actorRelationshipToPatient: nil // only required when we are creating dependent demographics
        )
        return demographics
    }
    
}
