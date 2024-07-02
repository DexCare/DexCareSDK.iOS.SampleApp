//
//  VisitTypeStepView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-01.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import SwiftUI

/// View used to capture the patients desired appointment type.
struct VisitTypeStepView: View {
    // MARK: Properties

    @ObservedObject var viewModel: VisitTypeStepViewModel

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch viewModel.viewState {
            case .loading:
                loadingView()
            case .loaded:
                contentView()
            case .error:
                emptyView()
            }
        }
        .navigationTitle("RegistrationStep.VisitType.Title")
        .alert(item: $viewModel.alertPresenter.alert) { context in
            context.alert
        }
        .onAppear {
            viewModel.loadProvider(forceLoad: false)
        }
    }

    // MARK: Lifecycle

    init(viewModel: VisitTypeStepViewModel) {
        self.viewModel = viewModel
    }

    // MARK: Private Views

    func contentView() -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: UIConstant.Spacing.defaultListCell16) {
                providerView()
                ForEach(viewModel.visitTypes, id: \.id) { visitType in
                    VisitTypeCell(visitType: visitType) {
                        viewModel.onVisitTypeSelected(visitType)
                    }
                }
            }
            .padding(.horizontal, UIConstant.Spacing.defaultSide16)
            .padding(.bottom, UIConstant.Spacing.defaultScrollViewBotton40)
            .padding(.top, UIConstant.Spacing.defaultScrollViewTop16)
        }
    }

    private func emptyView() -> some View {
        CustomEmptyView(
            image: Image(systemName: "exclamationmark.triangle.fill"),
            imageForegroundColor: .dxButtonPrimary,
            title: String(localized: "VisitType.FailedToLoad.Title"),
            description: String(localized: "VisitType.FailedToLoad.Description"),
            primaryButtonTitle: String(localized: "Common.TryAgainButton"),
            primaryButtonAction: {
                viewModel.loadProvider(forceLoad: true)
            }
        )
        .padding(UIConstant.Spacing.defaultSide16)
    }

    private func loadingView() -> some View {
        LoadingOverlayView(title: "RegistrationStep.LoadingVisitTypes")
    }

    // MARK: Private

    private func providerView() -> some View {
        Text(viewModel.providerTitle)
            .font(.dxH3)
            .foregroundColor(.dxTextPrimary)
    }
}

#Preview {
    VisitTypeStepView(viewModel: .init(visitScheduler: VisitScheduler.previewMock)
    )
}
