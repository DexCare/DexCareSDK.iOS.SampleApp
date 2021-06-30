//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import DexcareiOSSDK
import Lock
import PromiseKit
import Auth0

class Configuration: Decodable {
    var idpClientId: String
    var idpDomain: String
    var dexcareDomain: String
    var dexcareFhirOrchUrl: String
    var dexcareFhirOrchApiKey: String
    var dexcareVirtualVisitUrl: String
    var userAgent: String
    var tenantName: String
    var pushNotificationAppId: String
    var pushNotificationPlatform: String
    var brand: String
    var practiceId: String
    var loginEmail: String?
    var providerId: String?
    var stripeKey: String?
}

extension Configuration {
    enum Auth0Keys {
        static let appMetaData = "app_metadata"
        static let email = "email"
        static let scope = "openid offline_access"
    }
    
    var dexcareConfiguration: DexcareConfiguration {
        let virtualVisitConfig = VirtualVisitConfiguration(
            pushNotificationAppId: pushNotificationAppId,
            pushNotificationPlatform: pushNotificationPlatform,
            virtualVisitUrl: URL(string: dexcareVirtualVisitUrl)!
        )
        
        let environment = Environment(
            fhirOrchUrl: URL(string: dexcareFhirOrchUrl)!,
            virtualVisitConfiguration: virtualVisitConfig,
            dexcareAPIKey: dexcareFhirOrchApiKey
        )
        
        return DexcareConfiguration(
            environment: environment,
            userAgent: userAgent,
            domain: dexcareDomain,
            logger: ConsoleLogger()
        )
    }
}

extension Configuration {
    static func loadDefault() -> Configuration {
        return Configuration.load(tenantName: "acme")
    }
    
    static func load(tenantName: String) -> Configuration {
        let decoder = PropertyListDecoder()
        
        guard let plistURL = Bundle.main.url(forResource: tenantName, withExtension: "plist") else {
            fatalError("Could not find plist with name: \(tenantName)")
        }
        
        guard
            let data = try? Data.init(contentsOf: plistURL) else {
                fatalError("Error finding plist with name: \(tenantName)")
        }
        
        do {
            let config = try decoder.decode(Configuration.self, from: data)
            return config
        } catch {
            fatalError("Error creating Configuration object from from plist with name: \(tenantName) - \(error)")
        }
        
    }
}
