//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import DexcareiOSSDK

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
        auth0ClientId: configuration.idpClientId,
        auth0Domain: configuration.idpDomain
    )
    
    lazy var biometricsService: BiometricsServiceType = BiometricsService()
    
    lazy var loginStoreService: SecureLoginStoreType = {
        return KeychainLoginStore(biometricsService: biometricsService, logger: ConsoleLogger())
    }()

}
