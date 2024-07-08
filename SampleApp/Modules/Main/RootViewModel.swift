//
//  RootViewModel.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-06.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Combine
import Foundation

class RootViewModel: ObservableObject {
    // MARK: Properties

    @Published var authState: AuthState
    private var appServicesManager: AppServicesManagerType
    private var authService: Auth0AuthServiceType
    private var authStatePublisherSubscription: AnyCancellable?
    private var currentAppServicesPublisherSubscription: AnyCancellable?

    // MARK: Lifecycle

    init(appServicesManager: AppServicesManagerType = AppServicesManager.shared) {
        self.appServicesManager = appServicesManager
        authService = appServicesManager.current.authenticationService
        authState = authService.authState
        monitorAuthStateChanges()
        monitorAppServicesStateChanges()
    }

    // MARK: Private

    private func monitorAuthStateChanges() {
        authStatePublisherSubscription = authService
            .authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.authState = self.authService.authState
            }
    }

    private func monitorAppServicesStateChanges() {
        currentAppServicesPublisherSubscription = appServicesManager
            .currentPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                authStatePublisherSubscription?.cancel()
                self.authService = appServicesManager.current.authenticationService
                self.authState = self.authService.authState
                monitorAuthStateChanges()
            }
    }
}
