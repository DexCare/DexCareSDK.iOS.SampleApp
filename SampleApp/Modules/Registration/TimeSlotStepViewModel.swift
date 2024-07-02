//
//  TimeSlotStepViewModel.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-01.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

struct TimeSlotViewModelState {
    var startDate: Date
    var endDate: Date
    var timeSlots: [TimeSlot] = []
}

class TimeSlotStepViewModel: ObservableObject {
    // MARK: Properties

    @Published var alertPresenter: AlertPresenter = .init()
    @Published var providerTimeSlot: ProviderTimeSlot? = nil
    @Published var selectedTimeSlot: TimeSlot? = nil
    @Published var state: TimeSlotViewModelState
    @Published var viewState: ViewLoadingState = .loading
    @Published var selectedVisitDate: Date = .init() {
        didSet {
            selectedTimeSlot = nil
            updateTimeSlots(for: selectedVisitDate)
        }
    }

    private let navigationState: NavigationState
    private let providerService: ProviderService
    private let visitScheduler: VisitSchedulerType
    private let logger: LoggerType
    private let now: () -> Date
    private let providerNationalId: String

    // MARK: Lifecycle

    init(
        visitScheduler: VisitSchedulerType,
        providerNationalId: String = Current.configurationService.selectedAppConfiguration.providerNationalId,
        navigationState: NavigationState = Current.navigationState,
        providerService: ProviderService = Current.dexcareSDK.providerService,
        now: @escaping () -> Date = Current.now,
        logger: LoggerType = Current.logger
    ) {
        self.providerNationalId = providerNationalId
        self.navigationState = navigationState
        self.providerService = providerService
        self.logger = logger
        self.now = now
        self.visitScheduler = visitScheduler
        state = .init(startDate: now(), endDate: now())
    }

    // MARK: Internal Methods

    func loadTimeSlots(forceLoad: Bool) {
        if viewState == .loaded, !forceLoad {
            return
        }

        guard !providerNationalId.isEmpty else {
            viewState = .error
            logger.log("ProviderNationalId was not configured. Please update the Config.DexConfig file.", level: .error, sender: visitScheduler.logCategory)
            alertPresenter.present(.error(message: "RegistrationStep.AlertMessage.FailedToLoadTimeSlots"))
            return
        }

        guard let visitTypeShortName = visitScheduler.providerVisitType?.shortName else {
            logger.log("The 'VisitScheduler.providerVisitType' or it's 'shortName' name was not set.", level: .error, sender: visitScheduler.logCategory)
            alertPresenter.present(.error(message: "RegistrationStep.AlertMessage.FailedToLoadTimeSlots"))
            return
        }

        guard let ehrSystemName = visitScheduler.provider?.departments.first?.ehrSystemName else {
            logger.log("The 'VisitScheduler.provider' does not have a valid 'ehrSystemName'", level: .error, sender: visitScheduler.logCategory)
            alertPresenter.present(.error(message: "RegistrationStep.AlertMessage.FailedToLoadTimeSlots"))
            return
        }

        Task { @MainActor in
            do {
                viewState = .loading
                let daysAhead = try await providerService.getMaxLookaheadDays(visitTypeShortName: visitTypeShortName, ehrSystemName: ehrSystemName)
                providerTimeSlot = try await providerService.getProviderTimeSlots(
                    providerNationalId: providerNationalId,
                    visitTypeShortName: visitTypeShortName,
                    startDate: now(),
                    endDate: now().addDays(daysAhead)
                )
                self.state = .init(startDate: providerTimeSlot?.startDate ?? now(), endDate: providerTimeSlot?.endDate ?? now())
                self.selectedVisitDate = calculateFirstAvailableVisitDay(scheduleDays: providerTimeSlot?.scheduleDays ?? [])
                updateTimeSlots(for: self.selectedVisitDate)
                viewState = .loaded
            } catch {
                alertPresenter.present(.error(error))
                viewState = .error
            }
        }
    }

    func onContinueButtonTapped() {
        guard let selectedTimeSlot else {
            alertPresenter.present(.error(message: String(localized: "RegistrationStep.Field.TimeSlot.CannotBeEmptyMessage")))
            return
        }
        visitScheduler.updateTimeSlot(selectedTimeSlot)
        navigationState.push(.patientSelectionStep(visitScheduler: visitScheduler))
    }

    // MARK: Private

    private func calculateFirstAvailableVisitDay(scheduleDays: [ScheduleDay]) -> Date {
        let scheduleDays = scheduleDays.sorted { $0.date < $1.date }
        for scheduleDay in scheduleDays {
            if scheduleDay.timeSlots.count > 0 {
                return scheduleDay.date
            }
        }
        return now()
    }

    private func updateTimeSlots(for date: Date) {
        let timeZone = providerTimeSlot?.timeZone ?? TimeZone.current
        state.timeSlots = providerTimeSlot?.scheduleDays.first { $0.date.startOfDay(in: timeZone) == date.startOfDay(in: timeZone) }?.timeSlots ?? []
        logger.log("Time Slots count = \(state.timeSlots.count)", level: .debug, sender: visitScheduler.logCategory)
    }
}
