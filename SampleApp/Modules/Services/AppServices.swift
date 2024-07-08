//
//  AppServices.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-05.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

/// `Current` provides global access to app services dependencies
var Current: AppServices {
    AppServicesManager.shared.current
}

/// Structure used as our dependencies manager. It contains all the services that the app needs.
struct AppServices {
    // MARK: Properties

    var authenticationService: Auth0AuthServiceType
    var configurationService: ConfigurationServiceType
    var dexcareSDK: DexcareSDK
    var logger: LoggerType
    var navigationState: NavigationState
    var now: () -> Date
    var userDefaultsService: UserDefaultsServiceType

    // MARK: Lifecycle

    init(
        authenticationService: Auth0AuthServiceType,
        configurationService: ConfigurationServiceType,
        dexcareSDK: DexcareSDK,
        logger: LoggerType,
        navigationState: NavigationState,
        now: @escaping () -> Date,
        userDefaultsService: UserDefaultsServiceType
    ) {
        self.authenticationService = authenticationService
        self.configurationService = configurationService
        self.dexcareSDK = dexcareSDK
        self.logger = logger
        self.now = now
        self.navigationState = navigationState
        self.userDefaultsService = userDefaultsService
    }

    /// App Service live configuration
    static func live(appConfigurationId: String? = nil) -> AppServices {
        let logger = ConsoleLogger()
        let userDefaultsService = UserDefaultsService()
        var appConfigId = appConfigurationId
        if appConfigId == nil {
            appConfigId = userDefaultsService.getSelectedAppConfigurationId()
        }
        let configurationService: ConfigurationServiceType = ConfigurationService(
            fileName: "Config",
            selectedAppConfigurationId: appConfigId,
            logger: logger
        )
        let dexcareSDK = DexcareSDK(configuration: .init(config: configurationService.selectedAppConfiguration, logger: logger))

        return AppServices(
            authenticationService: Auth0AuthService(
                auth0ClientId: configurationService.selectedAppConfiguration.auth0ClientId,
                auth0Domain: configurationService.selectedAppConfiguration.auth0Domain,
                dexcareSDK: dexcareSDK,
                logger: logger,
                userDefaultsService: userDefaultsService
            ),
            configurationService: configurationService,
            dexcareSDK: dexcareSDK,
            logger: logger,
            navigationState: NavigationState(),
            now: Date.init,
            userDefaultsService: userDefaultsService
        )
    }
}
