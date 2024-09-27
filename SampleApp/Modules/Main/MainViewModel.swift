//
//  MainViewModel.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-06.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import SwiftUI

struct ProviderBookingSectionState {
    var isVisible: Bool
    var providerFullName: String
}

struct ResumeVirtualVisitSectionState {
    var viewState: ViewLoadingState
    var lastVisitId: String?
    var subtitle: String

    static func loading() -> ResumeVirtualVisitSectionState {
        .init(viewState: .loading, lastVisitId: nil, subtitle: String(localized: "MainView.LastVirtualVisit.RetrevingStatusMessage"))
    }

    static func loaded(lastVisitId: String?) -> ResumeVirtualVisitSectionState {
        let subtitle = lastVisitId != nil ? String(localized: "MainView.LastVirtualVisit.ResumeVisitSubtitle") : String(localized: "MainView.LastVirtualVisit.NoVisitSubtitle")
        return .init(viewState: .loaded, lastVisitId: lastVisitId, subtitle: subtitle)
    }

    static func error(errorMessage: String) -> ResumeVirtualVisitSectionState {
        .init(viewState: .error, subtitle: errorMessage)
    }
}

struct CancelVisitSectionState {
    var visitId: String
    var modality: VirtualVisitModality
    var reasons: [CancelReason]
    var email: String?
    var buttonTitle: String {
        modality == .phone ? String(localized: "MainView.CancelLastPhoneVisitButton") : String(localized: "MainView.CancelLastVideoVisitButton")
    }

    var sectionSubtitle: String = .init(localized: "MainView.CancelVisitSubtitle")
}

struct CancelReasonSelection: Identifiable {
    var id: String = UUID().uuidString
    var reasons: [CancelReason]
}

struct VirtualVisitSectionState {
    var viewState: ViewLoadingState
    var openRegions: [CustomPickerEntry<VirtualPracticeRegion>] = []
    var errorMessage: String?
    var isLoading: Bool

    static func loading() -> VirtualVisitSectionState {
        .init(viewState: .loading, isLoading: true)
    }

    static func loaded(openRegions: [CustomPickerEntry<VirtualPracticeRegion>]) -> VirtualVisitSectionState {
        .init(viewState: .loaded, openRegions: openRegions, isLoading: false)
    }

    static func error(errorMessage: String) -> VirtualVisitSectionState {
        .init(viewState: .error, errorMessage: errorMessage, isLoading: false)
    }
}

class MainViewModel: ObservableObject {
    // MARK: Propertie

    private var dexcareSDK: DexcareSDK
    private var appConfiguration: DexConfig
    private var appServicesManager: AppServicesManagerType
    private var authenticationService: Auth0AuthServiceType
    private var logger: LoggerType
    private(set) var navigationState: NavigationState
    private(set) var navigationTitle: String
    private var userDefaultsService: UserDefaultsServiceType
    @Published var alertPresenter: AlertPresenter = .init()
    @Published var isRegionPickerPresented: Bool = false
    @Published var lastVisitId: String?
    @Published var selectedRegion: VirtualPracticeRegion? {
        didSet {
            onRegionSelected(selectedRegion)
        }
    }

    @Published var selectedRegionName: String = ""
    @Published var resumeVisitSectionState: ResumeVirtualVisitSectionState
    @Published var virtualVisitSectionState: VirtualVisitSectionState
    @Published var providerBookingSectionState: ProviderBookingSectionState
    @Published var cancelVisitSectionState: CancelVisitSectionState?
    @Published var shouldShowReasons: CancelReasonSelection? = nil
    @Published var isLoadingViewPresented: Bool = false

    // MARK: Lifecycle

    init(
        appConfiguration: DexConfig = Current.configurationService.selectedAppConfiguration,
        appServicesManager: AppServicesManagerType = AppServicesManager.shared,
        authenticationService: Auth0AuthServiceType = Current.authenticationService,
        dexcareSDK: DexcareSDK = Current.dexcareSDK,
        logger: LoggerType = Current.logger,
        navigationState: NavigationState = Current.navigationState,
        userDefaultsService: UserDefaultsServiceType = Current.userDefaultsService
    ) {
        self.appConfiguration = appConfiguration
        self.appServicesManager = appServicesManager
        self.authenticationService = authenticationService
        self.dexcareSDK = dexcareSDK
        self.logger = logger
        self.navigationState = navigationState
        self.userDefaultsService = userDefaultsService
        providerBookingSectionState = ProviderBookingSectionState(
            isVisible: appConfiguration.supportedFeatures.contains(.providerBooking),
            providerFullName: appConfiguration.providerNationalIdFullName
        )
        virtualVisitSectionState = .loading()
        resumeVisitSectionState = .loading()
        navigationTitle = appConfiguration.configName
        self.dexcareSDK.virtualService.setVirtualEventDelegate(delegate: self)

        loadVirtualPractice(practiceId: appConfiguration.virtualPracticeId)

        lastVisitId = userDefaultsService.getLastVirtualVisitId()

        loadLastVirtualVisitId()
    }

    private func loadLastVirtualVisitId() {
        guard let lastVisitId = userDefaultsService.getLastVirtualVisitId() else {
            logger.log("No last virtual visit under way.", level: .debug, sender: .virtualVisit)
            resumeVisitSectionState = .loaded(lastVisitId: nil)
            return
        }
        resumeVisitSectionState = .loading()
        Task { @MainActor in
            do {
                let visit = try await dexcareSDK.virtualService.getVirtualVisit(visitId: lastVisitId)
                logger.log("Last Virtual Visit Status. Id: '\(lastVisitId)'. Status: '\(visit.status.rawValue)'", level: .debug, sender: .virtualVisit)
                let cancelReasons = await dexcareSDK.virtualService.fetchCancellationReasons()

                if visit.status.isActive(), let modality = visit.modality, !cancelReasons.isEmpty {
                    cancelVisitSectionState = .init(visitId: lastVisitId, modality: modality, reasons: cancelReasons)
                }

                let patient = try? await dexcareSDK.patientService.getPatient()
                cancelVisitSectionState?.email = patient?.demographicsLinks.first?.email

                if visit.status.isActive() {
                    self.resumeVisitSectionState = .loaded(lastVisitId: lastVisitId)
                } else {
                    self.resumeVisitSectionState = .loaded(lastVisitId: nil)
                    self.userDefaultsService.setLastVirtualVisitId(nil)
                }
            } catch {
                self.resumeVisitSectionState = .error(errorMessage: String(localized: "MainView.LastVirtualVisit.FailedToLoadStatus"))
            }
        }
    }

    // MARK: Internal Methods

    func logout() {
        authenticationService.logOut()
    }

    func resumeVirtualVisit() {
        guard let lastVisitId else {
            alertPresenter.present(.error(message: "Failed to start virtual visit."))
            return
        }

        guard let rootViewController = UIApplication.shared.firstKeyWindowRootViewController else {
            let errorMessage = "Failed to find root view to launch virtual visit"
            logger.log(errorMessage, level: .error, sender: .virtualVisit)
            alertPresenter.present(.error(message: errorMessage))
            return
        }
        Task { @MainActor in
            do {
                presentLoadingView(true)
                let patient = try await dexcareSDK.patientService.getPatient()
                try await dexcareSDK
                    .virtualService
                    .resumeVirtualVisit(
                        visitId: lastVisitId,
                        presentingViewController: rootViewController,
                        dexCarePatient: patient,
                        onCompletion: { [weak self] reason in
                            guard let self else { return }
                            presentLoadingView(false)
                            userDefaultsService.setLastVirtualVisitId(nil)
                            logVirtualVisitStats()
                            logger.log("Completed virtual visit. Reason = '\(reason)'", level: .verbose, sender: .virtualVisit)
                            presentAlert(reason: reason)
                        }
                    )
                logger.log("Virtual Visit resumed. id = '\(lastVisitId) '", level: .debug, sender: .virtualVisit)
            } catch {
                alertPresenter.present(.error(error))
                presentLoadingView(false)
            }
        }
    }

    func startProviderBookingFlow() {
        navigationState.push(.visitTypeStep(
            visitScheduler: VisitScheduler(
                brand: appConfiguration.brand,
                practiceId: appConfiguration.virtualPracticeId,
                practiceRegion: selectedRegion,
                schedulerVisitType: .providerBooking
            )
        ))
    }

    func startVirtualVisitFlow() {
        guard let selectedRegion else {
            logger.log(
                "A region needs to be selected before you can start the Virtual Visit Registration flow.",
                level: .warning,
                sender: .virtualVisit
            )
            return
        }
        navigationState.push(.patientSelectionStep(visitScheduler: VisitScheduler(
            brand: appConfiguration.brand,
            practiceId: appConfiguration.virtualPracticeId,
            practiceRegion: selectedRegion,
            schedulerVisitType: .virtualVisit
        )
        ))
    }

    func didTapCancelVisit() {
        guard let reasons = cancelVisitSectionState?.reasons else {
            return
        }
        shouldShowReasons = .init(reasons: reasons)
    }

    func didConfirmCancelVisitReason(cancelReason: CancelReason) {
        shouldShowReasons = nil
        guard let cancelVisitSectionState = cancelVisitSectionState else {
            return
        }

        presentLoadingView(true)
        defer {
            presentLoadingView(false)
        }
        Task { @MainActor in
            do {
                switch cancelVisitSectionState.modality {
                case .phone:
                    try await dexcareSDK.virtualService.cancelPhoneVisit(visitId: cancelVisitSectionState.visitId, reason: cancelReason.code, email: cancelVisitSectionState.email ?? "")
                default:
                    try await dexcareSDK.virtualService.cancelVideoVisit(visitId: cancelVisitSectionState.visitId, reason: cancelReason.code)
                }
                logger.log("\(cancelVisitSectionState.modality) visit cancelled. id = '\(cancelVisitSectionState.visitId) ' for reason = \(cancelReason.code)", level: .debug, sender: .virtualVisit)
                resumeVisitSectionState = .loaded(lastVisitId: nil)
                lastVisitId = nil
                userDefaultsService.setLastVirtualVisitId(nil)
                self.cancelVisitSectionState = nil
            } catch {
                alertPresenter.present(.error(error))
                presentLoadingView(false)
            }
        }
    }

    // MARK: Private

    private static func findRegion(_ regionId: String?, in regions: [VirtualPracticeRegion]) -> VirtualPracticeRegion? {
        regions.filter { $0.practiceRegionId == regionId }.first
    }

    private func loadVirtualPractice(practiceId: String) {
        virtualVisitSectionState = .loading()
        Task { @MainActor in
            do {
                let virtualPractice = try await self.dexcareSDK.practiceService.getVirtualPractice(practiceId: practiceId)
                let openRegions = Self.openRegions(for: virtualPractice)
                self.virtualVisitSectionState = .loaded(openRegions: Self.makeCustomPickerEntry(openRegions))
                self.selectedRegion = Self.findRegion(self.userDefaultsService.getSelectedPracticeRegionId(), in: openRegions)
                self.selectedRegionName = self.selectedRegion?.displayName ?? ""
            } catch {
                self.virtualVisitSectionState = .error(errorMessage: error.localizedDescription)
                logger.log("Failed to load virtual practice. Error: \(error)", level: .error, sender: .virtualVisit)
            }
        }
    }

    private func logVirtualVisitStats() {
        let stats = dexcareSDK.virtualService.getVideoCallStatistics()
        logger.log("Stats: \(String(describing: stats))", level: .debug, sender: .virtualVisit)
    }

    private func onRegionSelected(_ region: VirtualPracticeRegion?) {
        userDefaultsService.setSelectedPracticeRegionId(region?.practiceRegionId)
        selectedRegionName = region?.displayName ?? ""
        isRegionPickerPresented = false
        logger.log("Region '\(selectedRegionName)' was selected. Key = '\(region?.practiceRegionId ?? "")'", level: .debug, sender: .virtualVisit)
    }

    private static func makeCustomPickerEntry(_ regions: [VirtualPracticeRegion]) -> [CustomPickerEntry<VirtualPracticeRegion>] {
        regions
            .map {
                CustomPickerEntry(
                    title: $0.displayName,
                    subtitle: NumberFormatter.price.string(for: $0.visitPrice),
                    item: $0
                )
            }
    }

    private static func openRegions(for virtualPractice: VirtualPractice) -> [VirtualPracticeRegion] {
        virtualPractice
            .practiceRegions
            .filter { $0.active }
            .sorted { $0.displayName < $1.displayName }
    }

    private func presentLoadingView(_ present: Bool) {
        withTransaction(.disabledAnimationTransaction) {
            self.isLoadingViewPresented = present
        }
    }

    private func presentAlert(reason: VisitCompletionReason) {
        switch reason {
        case .completed,
             .phoneVisit,
             .left:
            return
        case .canceled,
             .alreadyInConference,
             .conferenceFull,
             .conferenceInactive,
             .conferenceNonExistent,
             .micAndCamNotConnected,
             .networkIssues,
             .exceededReconnectAttempt,
             .joinedElsewhere,
             .staffDeclined,
             .failed,
             .waitOffline:
            alertPresenter.present(.info(
                title: reason.alertTitle,
                message: reason.alertMessage,
                onOk: {}
            ))
        }
    }
}

extension MainViewModel: VirtualEventDelegate {
    func onWaitingRoomLaunched() {
        logger.log("Method onWaitingRoomLaunched() called", level: .verbose, sender: .virtualVisit)
    }

    func onWaitingRoomDisconnected() {
        logger.log("Method onWaitingRoomDisconnected() called", level: .verbose, sender: .virtualVisit)
    }

    func onWaitingRoomReconnecting() {
        logger.log("Method onWaitingRoomReconnecting() called", level: .verbose, sender: .virtualVisit)
    }

    func onWaitingRoomReconnected() {
        logger.log("Method onWaitingRoomReconnected() called", level: .verbose, sender: .virtualVisit)
    }

    func onWaitingRoomTransferred() {
        logger.log("Method onWaitingRoomTransferred() called", level: .verbose, sender: .virtualVisit)
    }

    func onVirtualVisitDisconnected() {
        logger.log("Method onVirtualVisitDisconnected() called", level: .verbose, sender: .virtualVisit)
    }

    func onVirtualVisitReconnecting() {
        logger.log("Method onVirtualVisitReconnecting() called", level: .verbose, sender: .virtualVisit)
    }

    func onVirtualVisitReconnected() {
        logger.log("Method onVirtualVisitReconnected() called", level: .verbose, sender: .virtualVisit)
    }

    func onVirtualVisitStarted() {
        logger.log("Method onVirtualVisitStarted() called", level: .verbose, sender: .virtualVisit)
    }

    func onVirtualVisitCompleted(reason _: DexcareiOSSDK.VisitCompletionReason) {
        logger.log("Method onVirtualVisitCompleted() called", level: .verbose, sender: .virtualVisit)
    }

    func onVirtualVisitCancelledByUser() {
        logger.log("Method onVirtualVisitCancelledByUser() called", level: .verbose, sender: .virtualVisit)
    }

    func onVirtualVisitModalityChanged(to value: VirtualVisitModality) {
        logger.log("Method onVirtualVisitConvertedTo() called with a \(value.rawValue) modality", level: .verbose, sender: .virtualVisit)
    }

    func onVirtualVisitDeclinedByProvider() {
        logger.log("Method onVirtualVisitDeclinedByProvider() called", level: .verbose, sender: .virtualVisit)
    }

    func onVirtualVisitError(error _: DexcareiOSSDK.VirtualVisitEventError) {
        logger.log("Method onVirtualVisitError() called", level: .verbose, sender: .virtualVisit)
    }

    func onDevicePairInitiated() {
        logger.log("Method onDevicePairInitiated() called", level: .verbose, sender: .virtualVisit)
    }
}
