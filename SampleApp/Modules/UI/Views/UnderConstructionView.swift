//
//  UnderConstructionView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-04.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// A view that allow us to display that a section is under construction
struct UnderConstructionView: View {
    // MARK: Properties

    var feature: String

    // MARK: Body

    var body: some View {
        VStack(alignment: .center, spacing: UIConstant.Spacing.large16) {
            Image(systemName: "wrench.and.screwdriver")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .foregroundColor(.dxTextSecondary)
                .padding(.bottom, UIConstant.Spacing.xlarge20)
            Text("UnderConstruction.Title")
                .font(.dxH4)
                .foregroundColor(.dxTextPrimary)

            Text(String(format: String(localized: "UnderConstruction.Message"), feature))
                .font(.dxBody1)
                .foregroundColor(.dxTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.dxTextSecondary, lineWidth: 2)
        )
    }
}

#Preview {
    UnderConstructionView(feature: "Paying by credit card")
}
