//
//  AppConfigurationCell.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-22.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// Cell representing an app/environment configuration (dev/staging/prod)
struct AppConfigurationCell: View {
    // MARK: Properties

    private let item: AppConfigurationMenuItem
    private let action: () -> Void

    // MARK: Lifecycle

    init(item: AppConfigurationMenuItem, action: @escaping () -> Void) {
        self.item = item
        self.action = action
    }

    // MARK: Body

    var body: some View {
        Button(action: action, label: {
            HStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 0) {
                colorView()
                contentView()
                    .layoutPriority(.high)
            }
            .background(Color.dxBackgroundSecondary)
        })
        .clipShape(RoundedRectangle(cornerRadius: UIConstant.CornerRadius.medium8))
        .cellShadow()
    }

    // MARK: Private Views

    private func contentView() -> some View {
        HStack(alignment: .center, spacing: UIConstant.Spacing.large16) {
            VStack(alignment: .leading, spacing: UIConstant.Spacing.xSmall4) {
                Text(item.title)
                    .font(.dxSubtitle1)
                    .foregroundColor(.dxTextPrimary)
                    .multilineTextAlignment(.leading)
                Text(item.description)
                    .font(.dxCaption)
                    .foregroundColor(.dxTextSecondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.dxAccent)
        }
        .padding(UIConstant.Spacing.large16)
    }

    private func colorView() -> some View {
        ZStack {
            Color.dxAccent
                .frame(width: 60)
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            AppConfigurationCell(
                item: AppConfigurationMenuItem(
                    id: "1",
                    title: "Dev",
                    description: "DexCare 'DEV' environment",
                    appConfiguration: .empty
                ),
                action: {}
            )
            AppConfigurationCell(
                item: AppConfigurationMenuItem(
                    id: "2",
                    title: "Staging",
                    description: "DexCare 'Staging' environment",
                    appConfiguration: .empty
                ),
                action: {}
            )
        }
        .padding()
    }
}
