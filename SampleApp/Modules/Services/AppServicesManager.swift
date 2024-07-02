//
//  AppServicesManager.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-01.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Combine
import Foundation

protocol AppServicesManagerType {
    var currentPublisher: AnyPublisher<AppServices, Never> { get }
    var current: AppServices { get }
    func udpateAppServices(_ newAppServices: AppServices)
}

/// This class allows us to change the current App Service. It allow us to switch between dev/stage/prod within the same app.
/// Other classes can register to this class and reload when the current app service is changed.
class AppServicesManager: AppServicesManagerType {
    // MARK: Singleton

    static let shared = AppServicesManager()

    // MARK: Properties

    @Published private(set) var current: AppServices {
        didSet {
            let currentConfig = current.configurationService.selectedAppConfiguration
            NSLog("Current AppServices: \(currentConfig.configId) - \(currentConfig.configName)")
        }
    }

    var currentPublisher: AnyPublisher<AppServices, Never> {
        $current.eraseToAnyPublisher()
    }

    // MARK: Lifecycle

    init() {
        current = .live()
    }

    // MARK: Internal Methods

    func udpateAppServices(_ newAppServices: AppServices) {
        current = newAppServices
    }
}
