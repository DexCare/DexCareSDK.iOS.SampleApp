//
//  CustomTextFieldStyle.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-05.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

// Custom TextField style for the Sample App
struct CustomTextFieldStyle: TextFieldStyle {
    // MARK: Properties

    var text: Binding<String>
    var title: LocalizedStringKey?
    var validation: ((String) -> String?)?
    @State var validationMessage: String?

    // MARK: Body

    func _body(configuration: TextField<Self._Label>) -> some View {
        CustomFieldView(
            title: title,
            content: { configuration },
            validationMessage: validationMessage
        )
        .onChange(of: text.wrappedValue) { _ in
            validationMessage = validation?(text.wrappedValue)
        }
    }

    // MARK: Lifecycle

    init(
        title: LocalizedStringKey? = nil,
        text: Binding<String>,
        validation: ((String) -> String?)?
    ) {
        self.title = title
        self.text = text
        self.validation = validation
    }
}

extension TextFieldStyle where Self == CustomTextFieldStyle {
    static func custom(
        title: LocalizedStringKey,
        text: Binding<String>,
        validation: ((String) -> String?)? = nil
    ) -> CustomTextFieldStyle {
        .init(title: title, text: text, validation: validation)
    }
}

#Preview {
    VStack {
        TextField("", text: .constant("John"))
            .textFieldStyle(.custom(title: "RegistrationStep.Field.FirstName.Title", text: .constant("")))
        TextField("", text: .constant("Doe"))
            .textFieldStyle(.custom(title: "RegistrationStep.Field.LastName.Title", text: .constant("")))
        TextField("", text: .constant("jdmail.com"))
            .textFieldStyle(.custom(title: "RegistrationStep.Field.Email.Title", text: .constant("")))
    }
    .padding()
}
