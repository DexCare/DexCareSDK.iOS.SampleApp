//
//  CouponCodePaymentView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-24.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// Sub view showing coupon code / service key payment options.
struct CouponCodePaymentView: View {
    // MARK: Properties

    @ObservedObject var viewModel: CouponCodePaymentViewModel

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
            Text("RegistrationStep.CouponCode.Instructions")
                .font(.dxBody1)
                .foregroundStyle(.dxTextPrimary)

            HStack(alignment: .bottom, spacing: UIConstant.Spacing.small8) {
                TextField("", text: $viewModel.couponCode)
                    .textFieldStyle(.custom(
                        title: "RegistrationStep.Field.CouponCode.Title",
                        text: $viewModel.couponCode
                    ))
                    .disableAutocorrection(true)

                Button {
                    viewModel.verifyCouponCode()
                } label: {
                    Text("Common.Button.Validate")
                }
                .buttonStyle(RectangleButtonStyle.tertiary)
            }
            Spacer()
        }
    }

    // MARK: Lifecycle

    init(viewModel: CouponCodePaymentViewModel) {
        self.viewModel = viewModel
    }
}

#Preview {
    CouponCodePaymentView(viewModel: .init(couponCode: "", presentAlert: { _ in }))
}
