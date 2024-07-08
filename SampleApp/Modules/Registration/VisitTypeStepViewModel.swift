//
//  VisitTypeStepViewModel.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-01.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

class VisitTypeStepViewModel: ObservableObject {
    // MARK: Properties

    @Published var alertPresenter: AlertPresenter = .init()
    @Published var viewState: ViewLoadingState = .loading
    @Published var visitTypes: [ProviderVisitType] = []
    @Published var providerTitle: String = ""
    private var provider: Provider? {
        didSet {
            providerTitle = "\(provider?.name ?? ""), \(provider?.credentials ?? "")"
        }
    }

    private let navigationState: NavigationState
    private let providerNationalId: String
    private let providerService: ProviderService
    private let visitScheduler: VisitSchedulerType
    private let logger: LoggerType

    // MARK: Lifecycle

    init(
        visitScheduler: VisitSchedulerType,
        providerNationalId: String = Current.configurationService.selectedAppConfiguration.providerNationalId,
        navigationState: NavigationState = Current.navigationState,
        providerService: ProviderService = Current.dexcareSDK.providerService,
        logger: LoggerType = Current.logger
    ) {
        self.providerNationalId = providerNationalId
        self.navigationState = navigationState
        self.providerService = providerService
        self.logger = logger
        self.visitScheduler = visitScheduler
    }

    // MARK: Internal Methods

    func loadProvider(forceLoad: Bool) {
        if viewState == .loaded, !forceLoad {
            return
        }

        guard !providerNationalId.isEmpty else {
            viewState = .error
            logger.log("'ProviderNationalId' was not configured. Please update the 'Config.DexConfig' file.", level: .error, sender: visitScheduler.logCategory)
            alertPresenter.present(.error(message: "RegistrationStep.AlertMessage.FailedToLoadProvider"))
            return
        }

        Task { @MainActor in
            do {
                viewState = .loading
                provider = try await providerService.getProvider(providerNationalId: providerNationalId)
                visitTypes = (provider?.visitTypes.filter { $0.shortName != nil }) ?? []
                viewState = .loaded
            } catch {
                viewState = .error
                alertPresenter.present(.error(error))
            }
        }
    }

    func onVisitTypeSelected(_ visitType: ProviderVisitType) {
        visitScheduler.updateProvider(provider)
        visitScheduler.updateVisitType(visitType)
        navigationState.push(.timeSlotStep(visitScheduler: visitScheduler))
    }
}
