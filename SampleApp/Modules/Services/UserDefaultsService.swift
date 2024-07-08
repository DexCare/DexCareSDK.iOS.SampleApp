//
//  UserDefaultsService.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-17.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

protocol UserDefaultsServiceType {
    func getLastVirtualVisitId() -> String?
    func setLastVirtualVisitId(_ value: String?)

    func getSelectedPracticeRegionId() -> String?
    func setSelectedPracticeRegionId(_ value: String?)

    func getSelectedAppConfigurationId() -> String?
    func setSelectedAppConfigurationId(_ value: String?)

    func clearAll()
}

/// Service used to store and retrived user defaults
class UserDefaultsService: UserDefaultsServiceType {
    // MARK: Keys

    private enum Key: String, CaseIterable {
        case selectedPracticeRegionId
        case selectedAppConfigurationId
        case lastVirtualVisitId
    }

    // MARK: Properties

    private var userDefaults: UserDefaults

    // MARK: Lifecycle

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: Last Visit id

    func getLastVirtualVisitId() -> String? {
        userDefaults.string(forKey: Key.lastVirtualVisitId.rawValue)
    }

    func setLastVirtualVisitId(_ value: String?) {
        userDefaults.set(value, forKey: Key.lastVirtualVisitId.rawValue)
    }

    // MARK: Default Practice Region Id

    func getSelectedPracticeRegionId() -> String? {
        userDefaults.string(forKey: Key.selectedPracticeRegionId.rawValue)
    }

    func setSelectedPracticeRegionId(_ value: String?) {
        userDefaults.set(value, forKey: Key.selectedPracticeRegionId.rawValue)
    }

    // MARK: Selected App Configuration Id

    func getSelectedAppConfigurationId() -> String? {
        userDefaults.string(forKey: Key.selectedAppConfigurationId.rawValue)
    }

    func setSelectedAppConfigurationId(_ value: String?) {
        userDefaults.set(value, forKey: Key.selectedAppConfigurationId.rawValue)
    }

    // MARK: Clear

    /// Clears all the user defaults
    func clearAll() {
        for key in Key.allCases {
            userDefaults.setValue(nil, forKey: key.rawValue)
        }
    }
}
