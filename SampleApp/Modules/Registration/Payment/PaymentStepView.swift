//
//  PaymentStepView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-18.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import SwiftUI

/// Payment step view.
struct PaymentStepView: View {
    @StateObject var viewModel: PaymentStepViewModel
    @State var isPaymentMethodPickerPresented: Bool = false

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
            paymentPickerField()
            paymentView()
            Spacer()
            startVisitButton()
        }
        .padding(.horizontal, UIConstant.Spacing.defaultSide16)
        .padding(.top, UIConstant.Spacing.defaultScrollViewTop16)
        .overlay {
            if viewModel.isLoadingViewPresented {
                LoadingOverlayView(title: "RegistrationStep.LoadingView.StartingVisit")
            }
        }
        .navigationTitle("RegistrationStep.Payment.Title")
        .alert(item: $viewModel.alertPresenter.alert) { context in
            context.alert
        }
    }

    // MARK: Lifecycle

    init(viewModel: PaymentStepViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private func paymentPickerField() -> some View {
        CustomPickerField(
            "RegistrationStep.Field.PaymentMethod.Title",
            text: $viewModel.state.paymentMethodDisplayString,
            presentationDetents: [.height(220), .medium],
            isPresented: $isPaymentMethodPickerPresented,
            presentingView: CustomPickerList(
                title: "RegistrationStep.Field.PaymentMethod.Title",
                instructions: "RegistrationStep.Field.PaymentMethod.Instructions",
                entries: viewModel.paymentEntries(),
                isPresented: $isPaymentMethodPickerPresented,
                selectedEntry: $viewModel.state.paymentMethod
            )
        )
    }

    @ViewBuilder
    private func paymentView() -> some View {
        if let paymentMethod = viewModel.state.paymentMethod {
            switch paymentMethod {
            case .couponCode:
                CouponCodePaymentView(viewModel: viewModel.couponCodeViewModel)
            case .insuranceSelf:
                InsurancePaymentView(viewModel: viewModel.insuranceViewModel)
            }

        } else {
            EmptyView()
        }
    }

    private func startVisitButton() -> some View {
        Button(action: {
            viewModel.onMainButtonTapped()
        }, label: {
            Text(viewModel.buttonTitle)
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(RectangleButtonStyle.primary)
    }
}

#Preview {
    PaymentStepView(viewModel: .init(visitScheduler: VisitScheduler.previewMock))
}
