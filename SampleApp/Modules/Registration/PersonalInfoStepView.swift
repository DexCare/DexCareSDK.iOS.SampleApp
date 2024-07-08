//
//  PersonalInfoStepView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-18.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import SwiftUI

/// View used to gather the patients personal information.
struct PersonalInfoStepView: View {
    // MARK: Properties

    @StateObject var viewModel: PersonalInfoStepViewModel
    @State var isGenderPickerPresented: Bool = false
    @State var isDatePickerPresented: Bool = false

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                myInfoView()
                    .padding(.horizontal, UIConstant.Spacing.defaultSide16)
                    .padding(.bottom, UIConstant.Spacing.defaultScrollViewBotton40)
                    .padding(.top, UIConstant.Spacing.defaultScrollViewTop16)
            }
            continueButton()
        }
        .navigationTitle("RegistrationStep.PersonalInfo.Title")
        .alert(item: $viewModel.alertPresenter.alert) { context in
            context.alert
        }
        .onDisappear {
            viewModel.saveState()
        }
    }

    // MARK: Lifecycle

    init(viewModel: PersonalInfoStepViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: Private views

    private func continueButton() -> some View {
        Button(action: {
            viewModel.onContinueButtonTapped()
        }, label: {
            Text("Common.Button.Continue")
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(RectangleButtonStyle.primary)
        .padding(.horizontal, UIConstant.Spacing.defaultSide16)
    }

    private func myInfoView() -> some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
            TextField("", text: $viewModel.state.patientFirstName)
                .textFieldStyle(.custom(
                    title: "RegistrationStep.Field.FirstName.Title",
                    text: $viewModel.state.patientFirstName,
                    validation: viewModel.validateFirstName
                ))
                .textContentType(.name)
                .autocorrectionDisabled()

            TextField("", text: $viewModel.state.patientLastName)
                .textFieldStyle(.custom(
                    title: "RegistrationStep.Field.LastName.Title",
                    text: $viewModel.state.patientLastName,
                    validation: viewModel.validateLastName
                ))
                .textContentType(.familyName)
                .autocorrectionDisabled()

            TextField("", text: $viewModel.state.patientEmail)
                .textFieldStyle(.custom(
                    title: "RegistrationStep.Field.Email.Title",
                    text: $viewModel.state.patientEmail,
                    validation: viewModel.validateEmailAddress
                ))
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)

            patientBirthdatePickerField()

            patientGenderPickerField()

            TextField("", text: $viewModel.state.patientLastFourSSN)
                .textFieldStyle(.custom(
                    title: "RegistrationStep.Field.SSN.Title",
                    text: $viewModel.state.patientLastFourSSN
                ))
                .keyboardType(.phonePad)

            TextField("", text: $viewModel.state.patientPhoneNumber)
                .textFieldStyle(.custom(
                    title: "RegistrationStep.Field.MobilePhoneNumber.Title",
                    text: $viewModel.state.patientPhoneNumber,
                    validation: viewModel.validatePhoneNumber
                ))
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)

            TextField("", text: $viewModel.state.patientAddressLine1)
                .textFieldStyle(.custom(
                    title: "RegistrationStep.Field.AddressLine1.Title",
                    text: $viewModel.state.patientAddressLine1
                ))
                .textContentType(.streetAddressLine1)
                .autocorrectionDisabled()

            TextField("", text: $viewModel.state.patientAddressLine2)
                .textFieldStyle(.custom(
                    title: "RegistrationStep.Field.AddressLine2.Title",
                    text: $viewModel.state.patientAddressLine2
                ))
                .textContentType(.streetAddressLine2)
                .autocorrectionDisabled()

            TextField("", text: $viewModel.state.patientCity)
                .textFieldStyle(.custom(
                    title: "RegistrationStep.Field.City.Title",
                    text: $viewModel.state.patientCity
                ))
                .textContentType(.addressCity)
                .autocorrectionDisabled()

            TextField("", text: $viewModel.state.patientState)
                .textFieldStyle(.custom(
                    title: "RegistrationStep.Field.State.Title",
                    text: $viewModel.state.patientState
                ))
                .textContentType(.addressState)
                .autocorrectionDisabled()

            TextField("", text: $viewModel.state.patientZipCode)
                .textFieldStyle(.custom(
                    title: "RegistrationStep.Field.ZipCode.Title",
                    text: $viewModel.state.patientZipCode,
                    validation: viewModel.validateZipCode
                ))
                .textContentType(.postalCode)
                .keyboardType(.numberPad)
        }
    }

    private func patientBirthdatePickerField() -> some View {
        CustomPickerField(
            "RegistrationStep.Field.Birthdate.Title",
            text: $viewModel.state.patientBirthdateDisplayString,
            presentationDetents: [.height(250)],
            isPresented: $isDatePickerPresented,
            presentingView: DatePickerView(
                selectedDate: $viewModel.state.patientBirthdate,
                isPresented: $isDatePickerPresented
            )
        )
    }

    private func patientGenderPickerField() -> some View {
        CustomPickerField(
            "RegistrationStep.Field.Gender.Title",
            text: $viewModel.state.patientGenderDisplayString,
            presentationDetents: [.height(220), .medium],
            isPresented: $isGenderPickerPresented,
            presentingView: CustomPickerList(
                title: "RegistrationStep.Field.Gender.Title",
                entries: Gender.allCases.map { CustomPickerEntry(title: $0.demographicStringValue, item: $0) },
                isPresented: $isGenderPickerPresented,
                selectedEntry: $viewModel.state.patientGender
            )
        )
        .onChange(of: viewModel.state.patientGender) { _ in
            isGenderPickerPresented = false
        }
    }
}

#Preview {
    PersonalInfoStepView(viewModel: PersonalInfoStepViewModel(visitScheduler: VisitScheduler.previewMock))
}
