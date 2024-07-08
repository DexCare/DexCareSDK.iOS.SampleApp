//
//  CustomTextEditor.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-08.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// Custom `TextEditor`
/// If you are using iOS17+, I would recommend creating your own TextEditoryStyle instead
struct CustomTextEditor: View {
    // MARK: Properties

    private let textEditor: () -> TextEditor
    private let title: LocalizedStringKey

    // MARK: Body

    var body: some View {
        CustomFieldView(
            title: title,
            content: {
                textEditor()
                    .scrollContentBackground(.hidden)
            }
        )
    }

    // MARK: Lifecycle

    init(title: LocalizedStringKey, textEditor: @escaping () -> TextEditor) {
        self.title = title
        self.textEditor = textEditor
    }
}

#Preview {
    VStack {
        CustomTextEditor(title: "RegistrationStep.Field.Reason.Title", textEditor: { TextEditor(text: .constant("")) })
    }
    .padding()
}
