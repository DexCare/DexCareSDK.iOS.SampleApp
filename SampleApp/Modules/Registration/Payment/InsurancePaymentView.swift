//
//  InsurancePaymentView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-23.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// Sub view showing insurance payment options.
struct InsurancePaymentView: View {
    @ObservedObject var viewModel: InsurancePaymentViewModel
    @State private var isInsurancePayersPickerPresented: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
            insurancePayerPicker()

            TextField("", text: $viewModel.state.memberId)
                .textFieldStyle(.custom(
                    title: LocalizedStringKey("RegistrationStep.Field.InsuranceMemberId.Title"),
                    text: $viewModel.state.memberId,
                    validation: viewModel.validateMemberId
                ))
                .textContentType(.none)
                .autocorrectionDisabled()
                .keyboardType(.asciiCapable)

            TextField("", text: $viewModel.state.groupId)
                .textFieldStyle(.custom(
                    title: LocalizedStringKey("RegistrationStep.Field.InsuranceGroupId.Title"),
                    text: $viewModel.state.groupId
                ))
                .textContentType(.none)
                .autocorrectionDisabled()
                .keyboardType(.asciiCapable)
        }
    }

    // MARK: Lifecycle

    init(viewModel: InsurancePaymentViewModel) {
        self.viewModel = viewModel
    }

    // MARK: Private Views

    @ViewBuilder
    private func insurancePayerPicker() -> some View {
        CustomPickerField(
            "RegistrationStep.Field.InsurancePayers.Title",
            text: $viewModel.state.selectedInsurancePayerString,
            isLoading: $viewModel.isInsurancePayerLoading,
            isPresented: $isInsurancePayersPickerPresented,
            presentingView: CustomPickerList(
                title: "RegistrationStep.Field.InsurancePayers.Title",
                instructions: "RegistrationStep.Field.InsurancePayers.Instructions",
                entries: viewModel.insurancePayerPickerEntries,
                isPresented: $isInsurancePayersPickerPresented,
                selectedEntry: $viewModel.state.selectedInsurancePayer
            )
        )
        if let errorMessage = viewModel.insurancePayerLoadingError {
            Text(errorMessage)
                .font(.dxBody1)
                .foregroundColor(Color.dxAlert)
        }
    }
}

#Preview {
    InsurancePaymentView(viewModel: .init())
        .padding()
}
