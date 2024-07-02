//
//  SampleAppData.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-19.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

/// Defines the app predefined sample data (.dexdata)
/// This is used to defined test personas.
struct SampleAppData: Decodable {
    var virtualVisitPatients: [VirtualVisitSamplePersona]

    static let empty: SampleAppData = .init(virtualVisitPatients: [])
}

/// Defines a test personas
struct VirtualVisitSamplePersona: Decodable {
    var id: String
    var extraInfo: VirtualVisitExtraInfoSampleData
    var patientDemographics: PatientDemographics
}

/// Defines test persona information that does not fit in the patient demographics structure.
struct VirtualVisitExtraInfoSampleData: Decodable {
    var title: String
    var visitReason: String?
    var paymentInfo: VirtualVisitPaymentInfoSampleData
}

/// Defines how the test persona will pay for their visit.
struct VirtualVisitPaymentInfoSampleData: Decodable {
    var paymentMethod: PaymentMethodSampleData
    var couponCode: String?
    var insurancePayerId: String?
    var insuranceMemberId: String?
    var insuranceGroupId: String?
}

/// Defines the test persona payment method.
enum PaymentMethodSampleData: String, Decodable {
    case couponCode
    case creditCard
    case insuranceSelf
}
