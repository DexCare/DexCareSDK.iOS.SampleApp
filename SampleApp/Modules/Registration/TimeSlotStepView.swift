//
//  TimeSlotStepView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-30.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// View use to pick the time and date of the visit.
struct TimeSlotStepView: View {
    // MARK: Properties

    private let timeSlotColumns: [GridItem] = [GridItem(.adaptive(minimum: 100))]
    @ObservedObject var viewModel: TimeSlotStepViewModel

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch viewModel.viewState {
            case .loading:
                loadingView()
            case .loaded:
                contentView()
            case .error:
                errorView()
            }
        }
        .navigationTitle("RegistrationStep.Schedule.Title")
        .alert(item: $viewModel.alertPresenter.alert) { context in
            context.alert
        }
        .onAppear {
            viewModel.loadTimeSlots(forceLoad: false)
        }
    }

    // MARK: Lifecycle

    init(viewModel: TimeSlotStepViewModel) {
        self.viewModel = viewModel
    }

    // MARK: Private Views

    private func contentView() -> some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
            ScrollView {
                VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
                    datePickerView()
                    timeSlotsView()
                    Spacer()
                }
                .padding(.horizontal, UIConstant.Spacing.defaultSide16)
                .padding(.bottom, UIConstant.Spacing.defaultScrollViewBotton40)
                .padding(.top, UIConstant.Spacing.defaultScrollViewTop16)
            }
            continueButton()
        }
    }

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

    private func datePickerView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("RegistrationStep.Field.TimeSlotDate.Title")
                .font(.dxBody1)
                .foregroundColor(.dxTextSecondary)
            HStack(alignment: .center) {
                DatePicker(
                    "RegistrationStep.Field.VisitDate.Title",
                    selection: $viewModel.selectedVisitDate,
                    in: viewModel.state.startDate ... viewModel.state.endDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .frame(width: 320) // The DatePicker seems to have an issue where it does not render properly the first time and will grow upon first date selection. Fixing the width to 320 seems to fix that issue: https://stackoverflow.com/questions/75461231
                .labelsHidden()
                .accentColor(.dxAccent)
                Spacer()
            }
        }
    }

    private func errorView() -> some View {
        CustomEmptyView(
            image: Image(systemName: "exclamationmark.triangle.fill"),
            imageForegroundColor: .dxButtonPrimary,
            title: String(localized: "TimeSlot.FailedToLoad.Title"),
            description: String(localized: "TimeSlot.FailedToLoad.Description"),
            primaryButtonTitle: String(localized: "Common.TryAgainButton"),
            primaryButtonAction: {
                viewModel.loadTimeSlots(forceLoad: true)
            }
        )
    }

    private func loadingView() -> some View {
        LoadingOverlayView(title: "RegistrationStep.LoadingTimeSlots")
    }

    @ViewBuilder
    private func timeSlotsView() -> some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
            Text("RegistrationStep.Field.TimeSlotTime.Title")
                .font(.dxBody1)
                .foregroundColor(.dxTextSecondary)

            if viewModel.state.timeSlots.count == 0 {
                CustomEmptyView(
                    title: String(localized: "RegistrationStep.NoTimeSlotToday.Title"),
                    description: String(localized: "RegistrationStep.NoTimeSlotToday.Instructions")
                )
                .padding(.top, UIConstant.Spacing.xxLarge24)
                .padding(.horizontal, UIConstant.Spacing.defaultSide16)
            } else {
                VStack {
                    LazyVGrid(columns: timeSlotColumns) {
                        ForEach(viewModel.state.timeSlots, id: \.slotId) { timeSlot in
                            TimeSlotCell(
                                timeSlot: timeSlot,
                                timeZone: viewModel.providerTimeSlot?.timeZone ?? TimeZone.current,
                                selectedTimeSlot: $viewModel.selectedTimeSlot
                            )
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TimeSlotStepView(viewModel: .init(visitScheduler: VisitScheduler.previewMock))
}
