//
//  CustomEmptyView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-08.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// View used when we have no content to display.
struct CustomEmptyView: View {
    // MARK: Properties

    private var image: Image?
    private var imageForegroundColor: Color?
    private var imageWidth: CGFloat
    private var title: String?
    private var description: String?
    private var primaryButtonTitle: String?
    private var primaryButtonAction: (() -> Void)?

    // MARK: Body

    var body: some View {
        VStack(alignment: .center, spacing: UIConstant.Spacing.large16) {
            imageView()
            titleView()
            descriptionView()
            primaryButtonView()
        }
    }

    // MARK: Lifecycle

    init(
        image: Image? = nil,
        imageForegroundColor: Color? = nil,
        imageWidth: CGFloat = 60,
        title: String? = nil,
        description: String? = nil,
        primaryButtonTitle: String? = nil,
        primaryButtonAction: (() -> Void)? = nil
    ) {
        self.image = image
        self.imageWidth = imageWidth
        self.imageForegroundColor = imageForegroundColor
        self.title = title
        self.description = description
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonAction = primaryButtonAction
    }

    // MARK: Private Views

    @ViewBuilder
    private func imageView() -> some View {
        if let image = image {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageWidth)
                .apply {
                    if let imageForegroundColor {
                        $0.foregroundColor(imageForegroundColor)
                    } else {
                        $0
                    }
                }
        }
    }

    @ViewBuilder
    private func titleView() -> some View {
        if let title = title, !title.isEmpty {
            Text(title)
                .font(.dxH3)
                .foregroundColor(.dxTextPrimary)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private func descriptionView() -> some View {
        if let description = description, !description.isEmpty {
            Text(description)
                .font(.dxBody1)
                .foregroundColor(.dxTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private func primaryButtonView() -> some View {
        if let primaryButtonTitle = primaryButtonTitle,
           let primaryButtonAction = primaryButtonAction,
           !primaryButtonTitle.isEmpty {
            Button(action: primaryButtonAction) {
                Text(primaryButtonTitle)
            }
            .buttonStyle(RectangleButtonStyle.primary)
        }
    }
}

#Preview {
    CustomEmptyView(
        image: Image(systemName: "exclamationmark.triangle"),
        title: "Your Title",
        description: "Your custom description",
        primaryButtonTitle: "Retry",
        primaryButtonAction: {}
    )
}
