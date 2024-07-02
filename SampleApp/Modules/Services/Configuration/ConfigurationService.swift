//
//  ConfigurationService.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-05.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

protocol ConfigurationServiceType {
    var appConfigurations: [DexConfig] { get }
    var selectedAppConfiguration: DexConfig { get }
    var sampleData: SampleAppData { get }
    func selectAppConfiguration(_ appConfiguration: DexConfig)
}

/// Service used to load the app configuration and sample data
class ConfigurationService: ConfigurationServiceType {
    // MARK: Properties

    private(set) var appConfigurations: [DexConfig]
    private(set) var selectedAppConfiguration: DexConfig
    private(set) var sampleData: SampleAppData
    private var logger: LoggerType

    // MARK: Lifecycle

    init(fileName: String, selectedAppConfigurationId: String?, logger: LoggerType) {
        self.logger = logger
        sampleData = Self.loadDexData(fileName: fileName, logger: logger)
        appConfigurations = Self.loadDexConfig(fileName: fileName)
        selectedAppConfiguration = appConfigurations.first(where: { $0.configId == selectedAppConfigurationId }) ?? appConfigurations.first ?? .empty
    }

    func selectAppConfiguration(_ appConfiguration: DexConfig) {
        selectedAppConfiguration = appConfiguration
    }

    // MARK: Private

    private static func loadDexConfig(fileName: String) -> [DexConfig] {
        let decoder = JSONDecoder()

        guard let jsonURL = Bundle.main.url(forResource: fileName, withExtension: "dexconfig") else {
            fatalError("Error: Unable to find '\(fileName)' configuration file")
        }

        guard let data = try? Data(contentsOf: jsonURL) else {
            fatalError("Error: Unable to find '\(fileName)' configuration file")
        }

        do {
            let appConfiguration = try decoder.decode([DexConfig].self, from: data)
            return appConfiguration
        } catch {
            fatalError("Error: Unable to deserialized \(fileName) configuration file - \(error)")
        }
    }

    private static func loadDexData(fileName: String, logger: LoggerType) -> SampleAppData {
        let decoder = JSONDecoder()

        guard let jsonURL = Bundle.main.url(forResource: fileName, withExtension: "dexdata") else {
            logger.log("Unable to find `\(fileName).dexdata`", level: .debug, sender: .configuration)
            return .empty
        }

        guard let data = try? Data(contentsOf: jsonURL) else {
            logger.log("Unable to load `\(fileName).dexdata`", level: .error, sender: .configuration)
            return .empty
        }

        do {
            let appConfiguration = try decoder.decode(SampleAppData.self, from: data)
            return appConfiguration
        } catch {
            logger.log("Unable to decode `\(fileName).dexdata`. Error: \(error)", level: .error, sender: .configuration)
            return .empty
        }
    }
}
