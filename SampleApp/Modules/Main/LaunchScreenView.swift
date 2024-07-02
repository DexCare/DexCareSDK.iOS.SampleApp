//
//  LaunchScreenView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-17.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// SwiftUI Version of the LaunchScreen that we use while we figure out if the user is already authenticated.
struct LaunchScreenView: View {
    // MARK: Body

    var body: some View {
        VStack(alignment: .center) {
            logo()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.dxAccent)
    }

    // MARK: Private Views

    private func logo() -> some View {
        Image("launchscreen.logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .padding(UIConstant.Spacing.defaultSide16)
    }

    private func progressView() -> some View {
        ProgressView()
            .progressViewStyle(.circular)
            .controlSize(.large)
            .tint(.white)
    }
}

#Preview {
    LaunchScreenView()
}
