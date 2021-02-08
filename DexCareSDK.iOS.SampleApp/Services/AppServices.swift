//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import DexcareSDK

class AppServices {
    static var shared: AppServices!
    
    lazy var dexcareSDK: DexcareSDK = {
        return DexcareSDK(configuration: self.configuration.dexcareConfiguration)
    }()
    
    lazy var configuration: Configuration = {
        return Configuration.load(tenantName: "acme")
    }()
    
    lazy var virtualService: VirtualServiceHelper = {
        return VirtualServiceHelper()
    }()
    
    lazy var retailService: RetailServiceHelper = {
        return RetailServiceHelper()
    }()
    
    lazy var auth0AccountService = Auth0AccountManager (
        auth0ClientId: configuration.auth0ClientId,
        auth0Domain: configuration.auth0Domain
    )
    
    lazy var biometricsService: BiometricsServiceType = BiometricsService()
    
    lazy var loginStoreService: SecureLoginStoreType = {
        return KeychainLoginStore(biometricsService: biometricsService, logger: ConsoleLogger())
    }()

}
