//  Copyright © 2020 DexCare. All rights reserved.

import DexcareiOSSDK
import Foundation
import PromiseKit

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
    var currentCatchmentArea: CatchmentArea?
    var currentPracticeId: String?
    var currentPracticeRegionId: String?
    var relationshipToPatient: RelationshipToPatient?
    var isDependentBooking: Bool = false

    var paymentType: PaymentMethod?

    func bookVirtualVisit(presentingViewController: UINavigationController, onCompletion: @escaping VisitCompletion, onSuccess: @escaping () -> Void, failure: @escaping (Error) -> Void) throws {
        try bookMyselfVirtualVisit(presentingViewController: presentingViewController, onCompletion: onCompletion, onSuccess: onSuccess, failure: failure)
    }

    func bookMyselfVirtualVisit(presentingViewController: UINavigationController, onCompletion: @escaping VisitCompletion, onSuccess: @escaping () -> Void, failure: @escaping (Error) -> Void) throws {
        firstly {
            try updatePatientDemographics()
        }.then { patient in
            try self.updateDependentDemographics().map { (patient, $0) }
        }.done { patient, dependentPatient in
            let isDependentBooking = self.isDependentBooking ?? false

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
            var combinedEmail: String?
            if isDependentBooking {
                combinedEmail = self.dependentEmail
            } else {
                combinedEmail = self.patientEmail
            }
            guard let patientEmail = combinedEmail else {
                throw "Missing patient email"
            }

            guard let catchmentArea = self.currentCatchmentArea else {
                throw "Missing catchmentArea"
            }

            var combinedPatient: DexcarePatient?
            if isDependentBooking {
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

            guard let practiceRegionId = self.currentPracticeRegionId else {
                throw "Missing practiceRegionId"
            }
            guard let currentRegionId = self.currentRegionId else {
                throw "Missing regionId (homeMarket)"
            }
            var combinedRelationship: RelationshipToPatient?
            if isDependentBooking {
                combinedRelationship = self.relationshipToPatient
                if combinedRelationship == nil {
                    throw "Missing relationshipToPatient"
                }
            }

            let virtualVisitDetails = VirtualVisitDetails(
                acceptedTerms: true,
                assignmentQualifiers: nil,
                patientDeclaration: isDependentBooking ? .other : .self,
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
                paymentMethod: self.paymentType ?? PaymentMethod.insuranceManualSelf(memberId: memberIdString!, providerId: providerIdString!),
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
        }
        .catch { error in
            failure("error starting virtual visit: \(error)")
        }
    }

    func updatePatientDemographics() throws -> Promise<DexcarePatient> {
        guard let regionId = currentRegionId else {
            throw "Missing RegionId"
        }
        guard let myselfInformation = myselfInformation else {
            throw "Missing myselfInformation"
        }
        guard let addressInformation = addressInformation else {
            throw "Missing addressInformation"
        }

        let patientDemographics = try buildMyselfDemographics(patientEmail: patientEmail, myselfInformation: myselfInformation, myselfAddress: addressInformation)
        let dexcareSDK = AppServices.shared.dexcareSDK
        let brand: String = AppServices.shared.configuration.brand

        return firstly {
            // Based on the region and user address, we get a Catchment Area that includes an EHRSystem
            return Promise<CatchmentArea> { resolver in
                dexcareSDK.patientService.getCatchmentArea(
                    visitState: regionId,
                    residenceState: addressInformation.address.state,
                    residenceZipCode: addressInformation.address.postalCode,
                    brand: brand, success: { catchmentArea in
                        resolver.fulfill(catchmentArea)
                    }
                ) { error in
                    resolver.reject(error)
                }
            }
        }.then { catchmentArea in
            Promise { seal in
                dexcareSDK.patientService.findOrCreatePatient(
                    inEhrSystem: catchmentArea.ehrSystem,
                    patientDemographics: patientDemographics,
                    success: {  patient in
                        self.currentCatchmentArea = catchmentArea
                        seal.fulfill(patient)
                    }, failure: { error in
                        print("error saving patient: \(error)")
                        seal.reject(error)
                    }
                )
            }
        }
    }

    func updateDependentDemographics() throws -> Promise<DexcarePatient?> {
        if !isDependentBooking {
            return Promise.value(nil)
        }
        guard let regionId = currentRegionId else {
            throw "Missing RegionId"
        }
        guard let dependentInformation = dependentInformation else {
            throw "Missing myselfInformation"
        }
        guard let addressInformation = dependentAddressInformation else {
            throw "Missing addressInformation"
        }

        let patientDemographics = try buildMyselfDemographics(patientEmail: dependentEmail, myselfInformation: dependentInformation, myselfAddress: addressInformation)

        let dexcareSDK = AppServices.shared.dexcareSDK
        let brand: String = AppServices.shared.configuration.brand

        return firstly {
            // Based on the region and user address, we get a Catchment Area that includes an EHRSystem
            return Promise<CatchmentArea> { resolver in
                dexcareSDK.patientService.getCatchmentArea(
                    visitState: regionId,
                    residenceState: addressInformation.address.state,
                    residenceZipCode: addressInformation.address.postalCode,
                    brand: brand, success: { catchmentArea in
                        resolver.fulfill(catchmentArea)
                    }
                ) { error in
                    resolver.reject(error)
                }
            }
        }.then { catchmentArea in
            Promise { seal in
                dexcareSDK.patientService.findOrCreateDependentPatient(
                    inEhrSystem: catchmentArea.ehrSystem,
                    dependentPatientDemographics: patientDemographics,
                    success: { patient in
                        self.currentCatchmentArea = catchmentArea
                        seal.fulfill(patient)
                    }, failure: { error in
                        print("error saving patient: \(error)")
                        seal.reject(error)
                    }
                )
            }
        }
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

    func getStripeToken(cardNumber: String, cardMonth: String, cardYear: String, cardCVC: String) -> Promise<String> {
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

        return Promise { seal in
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    print("ERROR  getting stripe token: \(error)")
                    seal.reject(error)
                } else {
                    guard let data = data else {
                        print("Empty data")
                        seal.reject("Empty data returned")
                        return
                    }

                    do {
                        // only need the ID out of the response
                        let object = try JSONDecoder().decode(StripeResponseObject.self, from: data)
                        seal.fulfill(object.id)
                    } catch {
                        seal.reject("error decoding stripe response: \(error)")
                    }
                }
            }.resume()
        }
    }
}
