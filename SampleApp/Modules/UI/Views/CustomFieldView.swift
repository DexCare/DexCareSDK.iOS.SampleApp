//
//  CustomFieldView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-06.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// View used to ensure that all fields (TextField, TextEditor and CustomPickerField have the same styling)
struct CustomFieldView<Content: View>: View {
    var title: LocalizedStringKey?
    var content: () -> Content
    var validationMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.small8) {
            titleView()
            contentView()
            validationMessageView()
        }
    }

    // MARK: Lifecycle

    init(
        title: LocalizedStringKey? = nil,
        content: @escaping () -> Content,
        validationMessage: String? = nil
    ) {
        self.title = title
        self.content = content
        self.validationMessage = validationMessage
    }

    // MARK: Private Views

    private func contentView() -> some View {
        content()
            .font(.dxBody1)
            .foregroundColor(.dxTextPrimary)
            .padding(.all, UIConstant.Spacing.small8)
            .background(RoundedRectangle(
                cornerRadius: UIConstant.CornerRadius.small4)
                .foregroundColor(.dxTextfieldBackground)
            )
    }

    private func titleView() -> some View {
        Text(title ?? "")
            .font(.dxBody1)
            .foregroundColor(.dxTextSecondary)
    }

    @ViewBuilder
    private func validationMessageView() -> some View {
        if let validationMessage {
            Text(validationMessage)
                .font(.dxCaption)
                .foregroundColor(.dxAlert)
        }
    }
}

#Preview {
    CustomFieldView(title: "RegistrationStep.Field.FirstName.Title", content: { TextEditor(text: .constant("")) })
}
