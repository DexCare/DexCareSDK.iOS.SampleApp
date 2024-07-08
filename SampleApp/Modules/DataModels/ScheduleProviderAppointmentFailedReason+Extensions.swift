//
//  ScheduleProviderAppointmentFailedReason+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-06-12.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation

extension ScheduleProviderAppointmentFailedReason {
    /// Returns an alert message for the `ScheduleProviderAppointmentFailedReason`
    var alertMessage: String {
        switch self {
        case .patientNotLinked:
            return String(localized: "ScheduleProviderAppointmentFaileReason.PatientNotLinked.AlertMessage")
        case .patientNotFound:
            return String(localized: "ScheduleProviderAppointmentFaileReason.PatientNotFound.AlertMessage")
        case .patientAccountLocked:
            return String(localized: "ScheduleProviderAppointmentFaileReason.PatientAccountLocked.AlertMessage")
        case .conflictSlotUnavailable:
            return String(localized: "ScheduleProviderAppointmentFaileReason.ConflictSlotUnavailable.AlertMessage")
        case .conflictPatientDoubleBooked:
            return String(localized: "ScheduleProviderAppointmentFaileReason.ConflictPatientDoubleBooked.AlertMessage")
        case .unknownAppointmentConflict:
            return String(localized: "ScheduleProviderAppointmentFaileReason.UnknownAppointmentConflict.AlertMessage")
        case .internalServerError:
            return String(localized: "ScheduleProviderAppointmentFaileReason.InternalServerError.AlertMessage")
        case let .missingInformation(message):
            return message
        case let .failed(reason):
            return reason.alertMessage
        case .patientNotOnPhysicalPanel:
            return String(localized: "ScheduleProviderAppointmentFaileReason.patientNotOnPhysicalPanel.AlertMessage")
        }
    }
}
