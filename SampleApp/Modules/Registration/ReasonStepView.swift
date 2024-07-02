//
//  ReasonStepView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-18.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import SwiftUI

/// View used to enter the patients reason for visit/
struct ReasonStepView: View {
    // MARK: Properties

    @StateObject var viewModel: ReasonStepViewModel

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
            reasonTextEditor()
            continueButton()
        }
        .padding(.horizontal, UIConstant.Spacing.defaultSide16)
        .padding(.top, UIConstant.Spacing.defaultScrollViewTop16)
        .navigationTitle("RegistrationStep.Reason.Title")
        .alert(item: $viewModel.alertPresenter.alert) { context in
            context.alert
        }
    }

    // MARK: Private Views

    private func continueButton() -> some View {
        Button(action: {
            viewModel.onContinueButtonTapped()
        }, label: {
            Text("Common.Button.Continue")
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(RectangleButtonStyle.primary)
    }

    private func reasonTextEditor() -> some View {
        CustomTextEditor(
            title: "RegistrationStep.Field.Reason.Title",
            textEditor: { TextEditor(text: $viewModel.state.visitReason) }
        )
    }
}

#Preview {
    ReasonStepView(viewModel: .init(visitScheduler: VisitScheduler.previewMock))
}
