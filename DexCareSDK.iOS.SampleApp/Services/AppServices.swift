//  Copyright © 2020 DexCare. All rights reserved.

import DexcareiOSSDK
import Foundation

struct AppServices {
    static var shared: AppServices!

    lazy var dexcareSDK: DexcareSDK = .init(configuration: self.configuration.dexcareConfiguration)

    lazy var configuration: Configuration = Configuration.load(tenantName: "acme")

    lazy var virtualService: VirtualServiceHelper = .init()

    lazy var retailService: RetailServiceHelper = .init()

    lazy var auth0AccountService = Auth0AccountManager(
        auth0ClientId: configuration.idpClientId,
        auth0Domain: configuration.idpDomain
    )

    lazy var biometricsService: BiometricsServiceType = BiometricsService()

    lazy var loginStoreService: SecureLoginStoreType = KeychainLoginStore(biometricsService: biometricsService, logger: ConsoleLogger())
}
