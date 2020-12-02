//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import DexcareSDK
import PromiseKit

class VirtualServiceHelper {
    var currentPatient: DexcarePatient?
    
    var currentRegionId: String?
    var myselfInformation: PersonInformation?
    var addressInformation: PersonDemographicAddress?
    var reasonForVisit: String?
    
    var patientEmail:String?
    var currentDexcarePatient: DexcarePatient?
    var currentVisitId: String?
    var currentInsurancePayer: InsurancePayer?
    var currentInsuranceMemberId: String?
  
    func bookVirtualVisit(presentingViewController: UINavigationController, onCompletion: @escaping VisitCompletion, onSuccess: @escaping () -> Void) throws {
        
        firstly {
            try updatePatientDemographics()
        }.done { [weak self] in
            
            guard let regionId = self?.currentRegionId else {
                throw "Missing RegionId"
            }
            guard let reasonForVisit = self?.reasonForVisit else {
                throw "Missing reason for visit"
            }
            
            guard let providerId = self?.currentInsurancePayer?.payerId, let memberId = self?.currentInsuranceMemberId else {
                throw "Missing Insurance Payer information"
            }
            
            guard let patientEmail = self?.patientEmail else {
                throw "Missing patient email"
            }
                
            let virtualVisitInformation = VirtualVisitInformation(
                visitReason: reasonForVisit,
                patientDeclaration: .self,
                currentState: regionId,
                acceptedTerms: true,
                userEmail: patientEmail,
                contactPhoneNumber: "(204)233-2332",
                preTriageTags: []
            )
            
            
            let dexcareSDK = AppServices.shared.dexcareSDK
            dexcareSDK.virtualService.startVirtualVisit(
                presentingViewController: presentingViewController,
                paymentMethod: PaymentMethod.insuranceManualSelf(memberId: memberId, providerId: providerId),
                virtualVisitInformation: virtualVisitInformation,
                onCompletion: onCompletion,
                success: { [weak self] visitId in
                    // successfully started a virtual visit. Save the visit id in case we need to resume
                    // Note: This test app doesn't do anything with it.
                    self?.currentVisitId = visitId
                    onSuccess()
                },
                failure: { error in
                    print("error starting virtual visit: \(error)")
            }
            )
        }
        .catch { error in
           print("error starting virtual visit: \(error)")
        }
    
    }
    
    func updatePatientDemographics() throws -> Promise<Void>{
        
        guard let regionId = currentRegionId else {
            throw "Missing RegionId"
        }
        guard let myselfInformation = myselfInformation else {
            throw "Missing myselfInformation"
        }
        guard let addressInformation = addressInformation else {
            throw "Missing myselfInformation"
        }
        
        let patientDemographics = try buildMyselfDemographics(myselfInformation: myselfInformation, myselfAddress: addressInformation)
        let brand: String = AppServices.shared.configuration.brand
        let dexcareSDK = AppServices.shared.dexcareSDK
        
        return Promise { seal in
            dexcareSDK.patientService.createPatient(
                usingVisitState: regionId,
                patientDemographics: patientDemographics,
                brand: brand,
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
        
        guard let email = patientEmail else {
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
