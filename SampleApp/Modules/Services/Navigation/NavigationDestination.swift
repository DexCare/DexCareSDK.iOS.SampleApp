//
//  NavigationDestination.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-11.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

struct NavigationDestination: Hashable {
    /// List of navigation destinations
    enum Destination {
        case personalInfoStep(VisitSchedulerType)
        case patientSelectionStep(VisitSchedulerType)
        case paymentStep(VisitSchedulerType)
        case reasonStep(VisitSchedulerType)
        case timeSlotStep(VisitSchedulerType)
        case visitTypeStep(VisitSchedulerType)
    }

    let destination: Destination
    private let id = UUID().uuidString

    private init(_ destination: Destination) {
        self.destination = destination
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        lhs.id == rhs.id
    }
}

extension NavigationDestination {
    static func patientSelectionStep(visitScheduler: VisitSchedulerType) -> NavigationDestination {
        NavigationDestination(.patientSelectionStep(visitScheduler))
    }

    static func paymentStep(visitScheduler: VisitSchedulerType) -> NavigationDestination {
        NavigationDestination(.paymentStep(visitScheduler))
    }

    static func personalInfoStep(visitScheduler: VisitSchedulerType) -> NavigationDestination {
        NavigationDestination(.personalInfoStep(visitScheduler))
    }

    static func reasonStep(visitScheduler: VisitSchedulerType) -> NavigationDestination {
        NavigationDestination(.reasonStep(visitScheduler))
    }

    static func timeSlotStep(visitScheduler: VisitSchedulerType) -> NavigationDestination {
        NavigationDestination(.timeSlotStep(visitScheduler))
    }

    static func visitTypeStep(visitScheduler: VisitSchedulerType) -> NavigationDestination {
        NavigationDestination(.visitTypeStep(visitScheduler))
    }
}
