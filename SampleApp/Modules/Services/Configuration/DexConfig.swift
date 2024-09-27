//
//  DexConfig.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-19.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

struct DexConfig: Decodable {
    /// A unique id that will identify this configuration.
    var configId: String
    /// The name of this configuration.
    var configName: String
    /// A short description of the configuration.
    var configDescription: String
    /// Auth0 client id.
    var auth0ClientId: String
    /// Auth0 domain
    var auth0Domain: String
    /// The brand name you will use in the app.
    var brand: String
    /// Your DexCare API Key.
    var dexcareApiKey: String
    /// Value added as the `domain` header on all api calls.
    var dexcareDomain: String
    /// FhirOrch service base URL.
    var dexcareFhirOrchUrl: String
    /// Virtual visit service base URL.
    var dexcareVirtualVisitUrl: String
    /// Provider national id used for the Provider Booking example.
    var providerNationalId: String
    /// Name of the provider that will be displayed in the provider booking flow example. It should match name returned by the provider API for the configured `providerNationalId`.
    var providerNationalIdFullName: String
    /// Configuration necessary to implement push notifications
    var pushNotification: PushNotificationConfig?
    /// Features that are supported by this configuration.
    var supportedFeatures: [SupportedFeature]
    /// The tenant environment used by your app.
    var tenant: String
    ///  The name of the app that will be sent in the "User-Agent" API header.
    var userAgent: String
    /// Virtual visit flow practice id.
    var virtualPracticeId: String

    static let empty = DexConfig(
        configId: "",
        configName: "",
        configDescription: "",
        auth0ClientId: "",
        auth0Domain: "",
        brand: "",
        dexcareApiKey: "",
        dexcareDomain: "",
        dexcareFhirOrchUrl: "",
        dexcareVirtualVisitUrl: "",
        providerNationalId: "",
        providerNationalIdFullName: "",
        pushNotification: nil,
        supportedFeatures: [],
        tenant: "",
        userAgent: "",
        virtualPracticeId: ""
    )

    static let preview = DexConfig(
        configId: "1",
        configName: "Dev",
        configDescription: "'DEV' Environment",
        auth0ClientId: "",
        auth0Domain: "",
        brand: "",
        dexcareApiKey: "",
        dexcareDomain: "",
        dexcareFhirOrchUrl: "",
        dexcareVirtualVisitUrl: "",
        providerNationalId: "",
        providerNationalIdFullName: "James Smith, MD",
        pushNotification: nil,
        supportedFeatures: [.providerBooking, .virtual, .retail],
        tenant: "",
        userAgent: "",
        virtualPracticeId: ""
    )
}

/// Push notication configuration
struct PushNotificationConfig: Decodable {
    /// Id provided by DexCare to identifiy your application
    var appId: String
    /// Push notification platform you want to use: `ios` or `ios-sandbox`.
    var platform: String
}

/// Features supported by the Sample App
enum SupportedFeature: String, Decodable {
    /// Provider booking flow.
    case providerBooking
    /// Retail booking flow.
    case retail
    /// Virtual booking flow.
    case virtual
    /// Unable to identified the feature.
    case unknown

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = SupportedFeature(rawValue: rawValue) ?? .unknown
    }
}
