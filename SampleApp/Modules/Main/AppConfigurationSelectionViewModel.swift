//
//  AppConfigurationSelectionViewModel.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-22.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Combine
import Foundation

struct AppConfigurationMenuItem {
    var id: String
    var title: String
    var description: String
    var appConfiguration: DexConfig
}

class AppConfigurationSelectionViewModel: ObservableObject {
    // MARK: Propertie

    @Published var isLoginScreenPresented: Bool = false
    private(set) var appConfigurationsMenuItems: [AppConfigurationMenuItem]
    private var appServicesManager: AppServicesManagerType
    private var configurationService: ConfigurationServiceType
    private var userDefaultsService: UserDefaultsServiceType

    // MARK: Lifecycle

    init(
        appServicesManager: AppServicesManagerType = AppServicesManager.shared,
        configurationService: ConfigurationServiceType = Current.configurationService,
        userDefaultsService: UserDefaultsServiceType = Current.userDefaultsService
    ) {
        self.appServicesManager = appServicesManager
        self.configurationService = configurationService
        self.userDefaultsService = userDefaultsService
        appConfigurationsMenuItems = Self.makeAppConfigurationsMenuItems(
            configurations: configurationService.appConfigurations
        )
    }

    // MARK: Internal Methods

    func appConfigurationSelected(_ menuItem: AppConfigurationMenuItem) {
        userDefaultsService.setSelectedAppConfigurationId(menuItem.appConfiguration.configId)
        appServicesManager.udpateAppServices(.live(appConfigurationId: menuItem.appConfiguration.configId))
        isLoginScreenPresented = true
    }

    // MARK: Private Methods

    private static func makeAppConfigurationsMenuItems(
        configurations: [DexConfig]
    ) -> [AppConfigurationMenuItem] {
        configurations.map { AppConfigurationMenuItem(
            id: $0.configId,
            title: $0.configName,
            description: $0.configDescription,
            appConfiguration: $0
        ) }
    }
}
