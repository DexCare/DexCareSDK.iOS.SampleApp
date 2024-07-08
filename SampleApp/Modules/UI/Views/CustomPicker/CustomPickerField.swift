//
//  CustomPickerField.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-13.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// Dropdown field that mimics the CustomTextField.
/// Tapping on this view will allow you to open a list.
struct CustomPickerField<Content: View>: View {
    // MARK: Properties

    @Binding var isPresented: Bool
    @Binding var isLoading: Bool
    @Binding private var text: String
    private let presentingView: Content
    private var title: LocalizedStringKey
    private var presentationDetents: Set<PresentationDetent>

    // MARK: Body

    var body: some View {
        CustomFieldView(
            title: title,
            content: {
                ZStack(alignment: .center) {
                    textField()
                    loadingView()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if !isLoading {
                        isPresented.toggle()
                    }
                }
            }
        )
        .sheet(isPresented: $isPresented) {
            presentingView
                .presentationDetents(presentationDetents)
        }
    }

    // MARK: Lifecycle

    init(
        _ title: LocalizedStringKey,
        text: Binding<String>,
        presentationDetents: Set<PresentationDetent> = [],
        isLoading: Binding<Bool> = .constant(false),
        isPresented: Binding<Bool>,
        presentingView: Content
    ) {
        self.title = title
        _text = text
        self.presentationDetents = presentationDetents
        _isPresented = isPresented
        _isLoading = isLoading
        self.presentingView = presentingView
    }

    // MARK: Private Views

    private func chevronView() -> some View {
        HStack(alignment: .center) {
            Spacer()
            Image(systemName: "chevron.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundColor(.dxTextSecondary)
                .padding(.trailing, UIConstant.Spacing.medium12)
        }
    }

    private func textField() -> some View {
        HStack {
            TextField("", text: $text)
                .disabled(true)
                .layoutPriority(.high)
            Spacer()
            chevronView()
        }
    }

    @ViewBuilder
    private func loadingView() -> some View {
        if isLoading {
            HStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.dxTextPrimary)
                Spacer()
            }
        }
    }
}

#Preview {
    VStack {
        CustomPickerField(
            "RegistrationStep.Field.Gender.Title",
            text: .constant(""),
            isPresented: .constant(false),
            presentingView: Text("VirtualVisit.Field.Gender.Title")
        )
        CustomPickerField(
            "RegistrationStep.Field.Birthdate.Title",

            text: .constant("April 12, 2000"),
            isPresented: .constant(false),
            presentingView: Text("RegistrationStep.Field.Birthdate.Title")
        )
        Spacer()
    }
    .padding()
}
