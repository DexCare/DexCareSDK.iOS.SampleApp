//  Copyright © 2020 DexCare. All rights reserved.

import DexcareiOSSDK
import Foundation
import UIKit

class VirtualServiceHelper {
    var currentRegionId: String?
    var myselfInformation: PersonInformation?
    var addressInformation: PersonDemographicAddress?
    var dependentInformation: PersonInformation?
    var dependentAddressInformation: PersonDemographicAddress?
    var dependentEmail: String?
    
    var reasonForVisit: String?

    var patientEmail: String?
    var currentDexcarePatient: DexcarePatient?
    var currentVisitId: String?
    var currentInsurancePayer: InsurancePayer?
    var currentInsuranceMemberId: String?
    var currentPracticeId: String?
    var currentPracticeRegionId: String?
    var currentEhrSystemName: String?
    var relationshipToPatient: RelationshipToPatient?
    var isDependentBooking: Bool = false

    var paymentType: PaymentMethod?

    func bookVirtualVisit(presentingViewController: UINavigationController, onCompletion: @escaping VisitCompletion, onSuccess: @escaping () -> Void, failure: @escaping (Error) -> Void) throws {
        Task {
            do {
                let patient = try await updatePatientDemographics()
                let dependentPatient = try await self.updateDependentDemographics()
                guard let reasonForVisit = self.reasonForVisit else {
                    throw "Missing reason for visit"
                }
                var providerIdString: String?
                var memberIdString: String?
                
                if self.paymentType == nil {
                    guard let providerId = self.currentInsurancePayer?.payerId, let memberId = self.currentInsuranceMemberId else {
                        throw "Missing Insurance Payer information"
                    }
                    providerIdString = providerId
                    memberIdString = memberId
                }
                let combinedEmail: String?
                if self.isDependentBooking {
                    combinedEmail = self.dependentEmail
                } else {
                    combinedEmail = self.patientEmail
                }
                guard let patientEmail = combinedEmail else {
                    throw "Missing patient email"
                }
                
                let combinedPatient: DexcarePatient?
                if self.isDependentBooking {
                    combinedPatient = dependentPatient
                } else {
                    combinedPatient = patient
                }
                
                guard let dexcarePatient = combinedPatient else {
                    throw "Missing dexcarePatient"
                }
                guard let practiceId = self.currentPracticeId else {
                    throw "Missing practiceId"
                }
                
                guard let currentRegionId = self.currentRegionId else {
                    throw "Missing regionId (homeMarket)"
                }
                var combinedRelationship: RelationshipToPatient?
                if self.isDependentBooking {
                    combinedRelationship = self.relationshipToPatient
                    if combinedRelationship == nil {
                        throw "Missing relationshipToPatient"
                    }
                }
                
                let virtualVisitDetails = VirtualVisitDetails(
                    acceptedTerms: true,
                    assignmentQualifiers: nil,
                    patientDeclaration: self.isDependentBooking ? .other : .self,
                    stateLicensure: currentRegionId,
                    visitReason: reasonForVisit,
                    visitTypeName: .virtual,
                    userEmail: patientEmail,
                    contactPhoneNumber: "(204)233-2332",
                    practiceId: practiceId,
                    assessmentToolUsed: nil,
                    brand: nil,
                    interpreterLanguage: nil,
                    preTriageTags: nil,
                    urgency: nil,
                    actorRelationshipToPatient: combinedRelationship,
                    homeMarket: nil,
                    initialStatus: nil
                )
                
                
                let dexcareSDK = AppServices.shared.dexcareSDK
                dexcareSDK.virtualService.createVirtualVisit(
                    presentingViewController: presentingViewController,
                    dexcarePatient: dexcarePatient,
                    virtualVisitDetails: virtualVisitDetails,
                    paymentMethod: self.paymentType ?? PaymentMethod.insuranceSelf(memberId: memberIdString!, payorId: providerIdString!),
                    actor: patient, // not used when booking for self.,
                    onCompletion: onCompletion,
                    success: { visitId in
                        // successfully started a virtual visit. Save the visit id in case we need to resume
                        // Note: This test app doesn't do anything with it.
                        self.currentVisitId = visitId
                        onSuccess()
                    },
                    failure: { error in
                        failure("error starting virtual visit: \(error)")
                    }
                )
            } catch {
                failure("error starting virtual visit: \(error)")
            }
        }
    }

    func updatePatientDemographics() async throws -> DexcarePatient {
        guard let ehrSystemName = currentEhrSystemName else {
            throw "Missing ehrSystemName"
        }
        guard let myselfInformation = myselfInformation else {
            throw "Missing myselfInformation"
        }
        guard let addressInformation = addressInformation else {
            throw "Missing addressInformation"
        }

        let patientDemographics = try buildMyselfDemographics(patientEmail: patientEmail, myselfInformation: myselfInformation, myselfAddress: addressInformation)
        let dexcareSDK = AppServices.shared.dexcareSDK
        let patient = try await dexcareSDK.patientService.findOrCreatePatient(
            inEhrSystem: ehrSystemName,
            patientDemographics: patientDemographics)
        
        return patient
    }

    func updateDependentDemographics() async throws -> DexcarePatient? {
        if !isDependentBooking {
            return nil
        }
        guard let ehrSystemName = currentEhrSystemName else {
            throw "Missing ehrSystemName"
        }
        guard let dependentInformation = dependentInformation else {
            throw "Missing myselfInformation"
        }
        guard let addressInformation = dependentAddressInformation else {
            throw "Missing addressInformation"
        }

        let patientDemographics = try buildMyselfDemographics(patientEmail: dependentEmail, myselfInformation: dependentInformation, myselfAddress: addressInformation)

        let dexcareSDK = AppServices.shared.dexcareSDK
        let patient = try await dexcareSDK.patientService.findOrCreateDependentPatient(
            inEhrSystem: ehrSystemName,
            dependentPatientDemographics: patientDemographics)
        
        return patient
    }

    private func buildMyselfDemographics(patientEmail: String?, myselfInformation: PersonInformation, myselfAddress: PersonDemographicAddress) throws -> PatientDemographics {
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
            birthdate: birthDate,
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

    func getStripeToken(cardNumber: String, cardMonth: String, cardYear: String, cardCVC: String) async throws -> String {
        /// In this simple example, we are using Stripe's Rest API in order to get the payment token
        /// You can also install the Stripe SDK which provides other means of getting the token as well as UI elements to help you.

        let tokenBuilder = URLRequestBuilder(baseURL: URL(string: "https://api.stripe.com/v1")!)

        let bearerToken = AppServices.shared.configuration.stripeKey!

        let request = tokenBuilder.post("tokens").token(bearerToken).queryItems([
            "card[number]": cardNumber,
            "card[exp_month]": cardMonth,
            "card[exp_year]": cardYear,
            "card[cvc]": cardCVC,
        ])

        do {
            let data = try await URLSession.shared.data(for: request)
            // only need the ID out of the response
            let object = try JSONDecoder().decode(StripeResponseObject.self, from: data.0)
            return object.id
        } catch {
            print("ERROR  getting stripe token: \(error)")
            throw error
        }
    }
}
