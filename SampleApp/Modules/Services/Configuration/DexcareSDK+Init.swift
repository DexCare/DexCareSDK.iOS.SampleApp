//
//  DexcareSDK+Init.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-19.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

extension DexcareConfiguration {
    /// Dexcare SDK initializer that takes a sample app configuration object (.dexconfig).
    init(config: DexConfig, logger: DexcareSDKLogger) {
        let virtualVisitConfig = VirtualVisitConfiguration(
            pushNotificationAppId: config.pushNotification?.appId ?? Bundle.main.bundleIdentifier ?? "app.id.undefined",
            pushNotificationPlatform: config.pushNotification?.platform ?? "ios-sandbox",
            virtualVisitUrl: URL(string: config.dexcareVirtualVisitUrl)!
        )
        let environment = Environment(
            fhirOrchUrl: URL(string: config.dexcareFhirOrchUrl)!,
            virtualVisitConfiguration: virtualVisitConfig,
            dexcareAPIKey: config.dexcareApiKey
        )
        self.init(
            environment: environment,
            userAgent: config.userAgent,
            domain: config.dexcareDomain,
            logger: logger
        )
    }
}
