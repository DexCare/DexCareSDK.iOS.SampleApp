//
//  VisitCompletionReason+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-22.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import SwiftUI

extension VisitCompletionReason {
    /// Returns an alert title for the `VisitCompletionReason`
    var alertTitle: String {
        switch self {
        case .completed:
            String(localized: "VisitCompletionReason.Completed.AlertTitle")
        case .canceled:
            String(localized: "VisitCompletionReason.Canceled.AlertTitle")
        case .left:
            String(localized: "VisitCompletionReason.Left.AlertTitle")
        case .alreadyInConference:
            String(localized: "VisitCompletionReason.AlreadyInConference.AlertTitle")
        case .conferenceFull:
            String(localized: "VisitCompletionReason.ConferenceFull.AlertTitle")
        case .conferenceInactive:
            String(localized: "VisitCompletionReason.ConferenceInactive.AlertTitle")
        case .conferenceNonExistent:
            String(localized: "VisitCompletionReason.ConferenceNonExistent.AlertTitle")
        case .micAndCamNotConnected:
            String(localized: "VisitCompletionReason.MicAndCamNotConnected.AlertTitle")
        case .networkIssues:
            String(localized: "VisitCompletionReason.NetworkIssues.AlertTitle")
        case .exceededReconnectAttempt:
            String(localized: "VisitCompletionReason.ExceededReconnectAttempt.AlertTitle")
        case .joinedElsewhere:
            String(localized: "VisitCompletionReason.JoinedElsewhere.AlertTitle")
        case .staffDeclined:
            String(localized: "VisitCompletionReason.StaffDeclined.AlertTitle")
        case .failed:
            String(localized: "VisitCompletionReason.Failed.AlertTitle")
        case .phoneVisit:
            String(localized: "VisitCompletionReason.PhoneVisit.AlertTitle")
        case .waitOffline:
            String(localized: "VisitCompletionReason.WaitOffline.AlertTitle")
        }
    }

    /// Returns an alert message for the `VisitCompletionReason`
    var alertMessage: String {
        switch self {
        case .completed:
            String(localized: "VisitCompletionReason.Completed.AlertMessage")
        case .canceled:
            String(localized: "VisitCompletionReason.Canceled.AlertMessage")
        case .left:
            String(localized: "VisitCompletionReason.Left.AlertMessage")
        case .alreadyInConference:
            String(localized: "VisitCompletionReason.AlreadyInConference.AlertMessage")
        case .conferenceFull:
            String(localized: "VisitCompletionReason.ConferenceFull.AlertMessage")
        case .conferenceInactive:
            String(localized: "VisitCompletionReason.ConferenceInactive.AlertMessage")
        case .conferenceNonExistent:
            String(localized: "VisitCompletionReason.ConferenceNonExistent.AlertMessage")
        case .micAndCamNotConnected:
            String(localized: "VisitCompletionReason.MicAndCamNotConnected.AlertMessage")
        case .networkIssues:
            String(localized: "VisitCompletionReason.NetworkIssues.AlertMessage")
        case .exceededReconnectAttempt:
            String(localized: "VisitCompletionReason.ExceededReconnectAttempt.AlertMessage")
        case .joinedElsewhere:
            String(localized: "VisitCompletionReason.JoinedElsewhere.AlertMessage")
        case .staffDeclined:
            String(localized: "VisitCompletionReason.StaffDeclined.AlertMessage")
        case .failed:
            String(localized: "VisitCompletionReason.Failed.AlertMessage")
        case .phoneVisit:
            String(localized: "VisitCompletionReason.PhoneVisit.AlertMessage")
        case .waitOffline:
            String(localized: "VisitCompletionReason.WaitOffline.AlertMessage")
        }
    }
}
