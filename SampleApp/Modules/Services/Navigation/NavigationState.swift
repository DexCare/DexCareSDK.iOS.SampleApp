//
//  NavigationState.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-09.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import SwiftUI

/// Keeps the current navigation state of the app
class NavigationState: ObservableObject {
    struct VirtualVisitRegistration: Hashable {
        var practiceRegion: VirtualPracticeRegion

        func hash(into hasher: inout Hasher) {
            hasher.combine(practiceRegion.practiceRegionId)
        }
    }

    @Published var path = NavigationPath()

    /// Push a given navigation destination onto the navigation stack.
    func push(_ navigationDestination: NavigationDestination) {
        path.append(navigationDestination)
    }

    /// Resets the navigation stack path.
    func popToRoot() {
        path = NavigationPath()
    }
}
