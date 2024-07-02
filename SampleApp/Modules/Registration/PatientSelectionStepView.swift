//
//  PatientSelectionStepView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-25.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import SwiftUI

/// View used to pick the patient (self, dependant, test personas)
struct PatientSelectionStepView: View {
    // MARK: Properties

    @StateObject var viewModel: PatientSelectionStepViewModel

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: UIConstant.Spacing.defaultListCell16) {
                patientsSection()
                testPersonasSection()
            }
            .padding(.horizontal, UIConstant.Spacing.defaultSide16)
            .padding(.bottom, UIConstant.Spacing.defaultScrollViewBotton40)
            .padding(.top, UIConstant.Spacing.defaultScrollViewTop16)
        }
        .navigationTitle("RegistrationStep.PatientSelection.Title")
        .alert(item: $viewModel.alertPresenter.alert) { context in
            context.alert
        }
    }

    // MARK: Lifecycle

    init(viewModel: PatientSelectionStepViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: Private views

    private func myselfButton() -> some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.small8) {
            Button(action: {
                viewModel.onMyselfButtonTapped()
            }, label: {
                HStack(spacing: UIConstant.Spacing.small8) {
                    Text("RegistrationStep.Button.Myself")
                    if viewModel.isPatientInformationLoading {
                        ProgressView().progressViewStyle(.circular).foregroundStyle(.dxTextLight)
                    }
                }
                .frame(maxWidth: .infinity)
            })
            .buttonStyle(RectangleButtonStyle.primary)
            .disabled(viewModel.isPatientInformationLoading || viewModel.patientInformationLoadingError != nil)

            if let validationMessage = viewModel.patientInformationLoadingError {
                Text(validationMessage)
                    .font(.dxCaption)
                    .foregroundColor(.dxAlert)
            }
        }
    }

    private func someoneElseButton() -> some View {
        Button(action: {
            viewModel.onSomeoneElseButtonTapped()
        }, label: {
            Text("RegistrationStep.Button.SomeoneElse")
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(RectangleButtonStyle.primary)
    }

    private func patientsSection() -> some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.defaultListCell16) {
            Text("RegistrationStep.PatientSelection.Instructions")
                .font(.dxBody1)
                .foregroundColor(.dxTextSecondary)
            myselfButton()
            someoneElseButton()
        }
    }

    private func testPersonaButton(persona: VirtualVisitSamplePersona) -> some View {
        Button(action: {
            viewModel.onPersonaButtonTapped(persona: persona)
        }, label: {
            Text(persona.extraInfo.title)
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(RectangleButtonStyle.primary)
    }

    @ViewBuilder
    private func testPersonasSection() -> some View {
        if viewModel.testPersonas.count > 0 {
            VStack(alignment: .leading, spacing: UIConstant.Spacing.defaultListCell16) {
                Text("RegistrationStep.TestPersonas.Title")
                    .font(.dxH4)
                    .padding(.top, UIConstant.Spacing.large16)
                Text("RegistrationStep.TestPersonas.Instructions")
                    .font(.dxBody1)
                    .foregroundColor(.dxTextSecondary)
                ForEach(viewModel.testPersonas, id: \.id) { testPersona in
                    testPersonaButton(persona: testPersona)
                }
            }
        }
    }
}

#Preview {
    PatientSelectionStepView(viewModel: PatientSelectionStepViewModel(visitScheduler: VisitScheduler.previewMock))
}
