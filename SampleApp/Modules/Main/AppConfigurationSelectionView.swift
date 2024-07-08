//
//  AppConfigurationSelectionView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-22.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// View used to select the sample app configuration/environment
struct AppConfigurationSelectionView: View {
    // MARK: Properties

    @StateObject var viewModel = AppConfigurationSelectionViewModel()

    // MARK: Body

    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                VStack(alignment: .center, spacing: UIConstant.Spacing.xxxxLarge40) {
                    logoView()
                    greetingsView()
                    if viewModel.appConfigurationsMenuItems.count > 0 {
                        environmentsView()
                    } else {
                        emptyView()
                    }
                }
                .padding(.top, UIConstant.Spacing.defaultScrollViewTop16)
                .padding(.bottom, UIConstant.Spacing.defaultScrollViewBotton40)
                .padding(.horizontal, UIConstant.Spacing.defaultSide16)
            }
            poweredByDexCareView()
        }
        .fullScreenCover(isPresented: $viewModel.isLoginScreenPresented) {
            LoginView()
        }
    }

    // MARK: Private Views

    private func emptyView() -> some View {
        VStack(alignment: .center, spacing: UIConstant.Spacing.xxxxLarge40) {
            Divider()
            CustomEmptyView(
                title: String(
                    localized: "EnvironmentSelectionView.NoEnvironmentConfigured.Title"),
                description: String(localized: "EnvironmentSelectionView.NoEnvironmentConfigured.Message")
            )
        }
    }

    private func environmentsView() -> some View {
        VStack(alignment: .center, spacing: UIConstant.Spacing.large16) {
            Text("EnvironmentSelectionView.Greetings.Instructions")
                .font(.dxBody1)
                .foregroundStyle(.dxTextPrimary)
                .multilineTextAlignment(.center)
            ForEach(viewModel.appConfigurationsMenuItems, id: \.id) { menu in
                AppConfigurationCell(item: menu, action: {
                    viewModel.appConfigurationSelected(menu)
                })
            }
        }
    }

    private func greetingsView() -> some View {
        VStack(alignment: .center, spacing: UIConstant.Spacing.large16) {
            Text("EnvironmentSelectionView.Greetings.Title")
                .font(.dxH1)
                .foregroundStyle(.dxTextPrimary)
                .multilineTextAlignment(.center)
        }
    }

    private func logoView() -> some View {
        Image("acme.logo.template")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.dxAccent)
            .frame(width: 240)
    }

    private func poweredByDexCareView() -> some View {
        HStack(alignment: .bottom) {
            Text("EnvironmentSelectionView.PoweredBy")
                .font(.dxBody1)
                .foregroundColor(.dxTextPrimary)
            Image("dexcare.logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 24)
        }
        .padding(.horizontal, UIConstant.Spacing.defaultSide16)
    }
}

#Preview {
    AppConfigurationSelectionView()
}
