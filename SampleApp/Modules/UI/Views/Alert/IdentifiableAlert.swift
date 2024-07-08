//
//  IdentifiableAlert.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-20.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import SwiftUI

/// Wrapper around alerts that allow us to make them identifiable
struct IdentifiableAlert: Identifiable {
    var id: String
    var alert: Alert

    init(id: String, alert: Alert) {
        self.id = id
        self.alert = alert
    }

    /// Creates a generic "error" alert
    static func error(title: String = String(localized: "Alert.Error.Generic.Title"), message: String) -> IdentifiableAlert {
        IdentifiableAlert(
            id: "Alert.CustomAlert",
            alert: Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: .default(Text("Common.Button.OK"))
            )
        )
    }

    /// Creates an alert from the provided `Error`.
    /// Notes: The copy of these errors is for development purpose only, they are there to help troubleshoot issues when implementing the SDK. These are not intended for consumer of your application.
    static func error(_ error: Error) -> IdentifiableAlert {
        switch error {
        case let failedReason as FailedReason:
            return makeFailedReasonAlert(failedReason)
        case let failedReason as CouponCodeFailedReason:
            return makeCouponCodeErrorAlert(failedReason)
        case let failedReason as VirtualVisitFailedReason:
            return makeVirtualVisitErrorAlert(failedReason)
        case let failedReason as ScheduleProviderAppointmentFailedReason:
            return makeScheduleProviderAppointmentFaileReason(failedReason)
        default:
            return makeGenericErrorAlert(error)
        }
    }

    /// Creates a generic "info" alert
    static func info(title: String, message: String, onOk: (() -> Void)? = {}) -> IdentifiableAlert {
        IdentifiableAlert(
            id: "Alert.Info",
            alert: Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: .default(Text("Common.Button.OK"), action: onOk)
            )
        )
    }

    /// Creates a generic "success" alert
    static func success(title: String = String(localized: "Alert.Success.Title"), message: String) -> IdentifiableAlert {
        IdentifiableAlert(
            id: "Alert.Success",
            alert: Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: .default(Text("Common.Button.OK"))
            )
        )
    }

    // MARK: Private

    /// Creates an alert for the `CouponCodeFailedReason`
    static func makeCouponCodeErrorAlert(_ failedReason: CouponCodeFailedReason) -> IdentifiableAlert {
        IdentifiableAlert(
            id: "Alert.Error.CouponCode",
            alert: Alert(
                title: Text("Alert.Error.CouponCode.Title"),
                message: Text(failedReason.alertMessage),
                dismissButton: .default(Text("Common.Button.OK"))
            )
        )
    }

    /// Creates an alert for the `FailedReason`
    static func makeFailedReasonAlert(_ failedReason: FailedReason) -> IdentifiableAlert {
        IdentifiableAlert(
            id: "Alert.FailedReason",
            alert: Alert(
                title: Text("Alert.Error.Generic.Title"),
                message: Text(failedReason.alertMessage),
                dismissButton: .default(Text("Common.Button.OK"))
            )
        )
    }

    /// Creates an alert for a generic `Error`. This is used when we find an error that we cannot process/identify.
    static func makeGenericErrorAlert(_ error: Error) -> IdentifiableAlert {
        IdentifiableAlert(
            id: "Alert.UnknownError",
            alert: Alert(
                title: Text("Alert.Error.Unhandled.Title"),
                message: Text(String(format: String(localized: "Alert.Error.Unhandled.Message"), error.localizedDescription)),
                dismissButton: .default(Text("Common.Button.OK"))
            )
        )
    }

    /// Creates an alert for the `ScheduleProviderAppointmentFailedReason`
    static func makeScheduleProviderAppointmentFaileReason(_ failedReason: ScheduleProviderAppointmentFailedReason) -> IdentifiableAlert {
        IdentifiableAlert(
            id: "Alert.ScheduleProviderAppointmentFaileReason",

            alert: Alert(
                title: Text("Alert.Error.Generic.Title"),
                message: Text(failedReason.alertMessage),
                dismissButton: .default(Text("Common.Button.OK"))
            )
        )
    }

    /// Creates an alert for the `VirtualVisitFailedReason`
    static func makeVirtualVisitErrorAlert(_ failedReason: VirtualVisitFailedReason) -> IdentifiableAlert {
        IdentifiableAlert(
            id: "Alert.VirtualVisitFailedReason",
            alert: Alert(
                title: Text("Alert.Error.Generic.Title"),
                message: Text(failedReason.alertMessage),
                dismissButton: .default(Text("Common.Button.OK"))
            )
        )
    }
}
