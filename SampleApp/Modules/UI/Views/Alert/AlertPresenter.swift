//
//  AlertPresenter.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-13.
//  Copyright © 2024 DexCare. All rights reserved.

import DexcareiOSSDK
import SwiftUI

/// Structure that helps managing alerts in SwiftUI.
/// It allows the view to bind to the `AlertPresenter` and then the ViewModel can
/// call `.present()` when you need to display an alert.
///
/// Usage:
/// In your ViewModel, create a @Published property:
/// ```
/// @Published var alertPresenter: AlertPresenter
/// ```
///
/// In your view, bind the `alert` to your `alertPresenter`:
/// ```
/// .alert(item: $viewModel.alertPresenter.alert) { context in
///    context.alert
/// }
/// ```
///
///  Then in your view model present your alert when needed:
/// ```
/// alertPresenter.present(alert)
/// ```
struct AlertPresenter {
    var alert: IdentifiableAlert?

    mutating func present(_ alert: IdentifiableAlert) {
        self.alert = alert
    }
}
