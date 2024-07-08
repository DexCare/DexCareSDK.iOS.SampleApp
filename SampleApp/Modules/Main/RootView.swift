//
//  RootView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-06.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// Sample app root view.
struct RootView: View {
    // MARK: Properties

    @StateObject private var viewModel = RootViewModel()

    // MARK: Body

    var body: some View {
        contentView()
    }

    // MARK: Private Views

    @ViewBuilder
    private func contentView() -> some View {
        switch viewModel.authState {
        case .unknown:
            LaunchScreenView()
        case .unauthenticated:
            AppConfigurationSelectionView()
        case .authenticated:
            MainView()
        }
    }
}

#Preview {
    RootView()
}
