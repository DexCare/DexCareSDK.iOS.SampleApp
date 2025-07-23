//
//  MainView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-05.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import SwiftUI

/// View where all the sample app examples are displayed.
struct MainView: View {
    // MARK: Properties

    @ObservedObject var viewModel = MainViewModel()
    @ObservedObject var navigationState: NavigationState

    // MARK: Body

    var body: some View {
        NavigationStack(path: $navigationState.path) {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: UIConstant.Spacing.xxxLarge32) {
                        virtualVisitView()
                        resumeVirtualVisitView()
                        cancelVisitView
                        providerBookingView()
                        sdkVersionView()
                    }
                    .padding(UIConstant.Spacing.defaultSide16)
                }
                logoutButton()
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if viewModel.isLoadingViewPresented {
                    LoadingOverlayView(title: "MainView.LastVirtualVisit.LoadingView.ResumingVisit")
                }
            }
            .alert(item: $viewModel.alertPresenter.alert) { context in
                context.alert
            }
            .navigationDestination(for: NavigationDestination.self) { param in
                switch param.destination {
                case let .patientSelectionStep(visitScheduler):
                    PatientSelectionStepView(viewModel: .init(visitScheduler: visitScheduler))
                case let .paymentStep(visitScheduler):
                    PaymentStepView(viewModel: .init(visitScheduler: visitScheduler))
                case let .personalInfoStep(visitScheduler):
                    PersonalInfoStepView(viewModel: .init(visitScheduler: visitScheduler))
                case let .reasonStep(visitScheduler):
                    ReasonStepView(viewModel: .init(visitScheduler: visitScheduler))
                case let .timeSlotStep(visitScheduler):
                    TimeSlotStepView(viewModel: .init(visitScheduler: visitScheduler))
                case let .visitTypeStep(visitScheduler):
                    VisitTypeStepView(viewModel: .init(visitScheduler: visitScheduler))
                }
            }
            .sheet(item: $viewModel.shouldShowReasons) { sheetState in
                CancelVisitView(
                    reasons: sheetState.reasons,
                    onReasonSelected: viewModel.didConfirmCancelVisitReason
                )
            }
        }
    }

    // MARK: Lifecycle

    init(navigationState: NavigationState = Current.navigationState) {
        self.navigationState = navigationState
    }

    // MARK: Private views

    @ViewBuilder
    private var cancelVisitView: some View {
        if let cancelVisitSectionState = viewModel.cancelVisitSectionState {
            VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
                Text(cancelVisitSectionState.sectionSubtitle)
                    .font(.dxBody1)
                    .foregroundColor(.dxTextPrimary)
                Button {
                    viewModel.didTapCancelVisit()
                } label: {
                    Text(cancelVisitSectionState.buttonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(RectangleButtonStyle.secondary)
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func resumeVirtualVisitView() -> some View {
        if viewModel.resumeVisitSectionState.isVisible {
            VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
                Text("MainView.LastVirtualVisit.Title")
                    .font(.dxH4)
                    .foregroundColor(.dxTextPrimary)
                Text(viewModel.resumeVisitSectionState.subtitle)
                    .font(.dxBody1)
                    .foregroundColor(viewModel.resumeVisitSectionState.viewState == .error ? .dxAlert : .dxTextPrimary)
                switch viewModel.resumeVisitSectionState.viewState {
                case .loading:
                    HStack(spacing: 0) {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(.circular)
                            .foregroundColor(.dxTextPrimary)
                        Spacer()
                    }
                case .loaded:
                    Button {
                        viewModel.resumeVirtualVisit()
                    } label: {
                        Text("MainView.LastVirtualVisit.ResumeVisitButton")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(RectangleButtonStyle.primary)
                    .disabled(viewModel.resumeVisitSectionState.lastVisitId == nil)
                case .error:
                    EmptyView()
                }
            }
        }
    }

    private func logoutButton() -> some View {
        Button(action: {
            viewModel.logout()
        }, label: {
            Text("Common.Button.Logout")
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(RectangleButtonStyle.secondary)
        .padding(.vertical, UIConstant.Spacing.medium12)
        .padding(.horizontal, UIConstant.Spacing.defaultSide16)
    }

    @ViewBuilder
    private func providerBookingView() -> some View {
        if viewModel.providerBookingSectionState.isVisible {
            VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
                Text("MainView.ProviderBooking.Title")
                    .font(.dxH4)
                    .foregroundColor(.dxTextPrimary)
                Text("MainView.ProviderBooking.Subtitle")
                    .font(.dxBody1)
                    .foregroundColor(.dxTextPrimary)
                providerCardView()
            }
        }
    }

    private func providerCardView() -> some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
            Text(viewModel.providerBookingSectionState.providerFullName)
                .font(.dxH3)
                .foregroundColor(.dxTextLight)
            Button(action: {
                viewModel.startProviderBookingFlow()
            }, label: {
                Text("MainView.ProviderBooking.Button.ScheduleAVisit")
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(RectangleButtonStyle.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.dxAccent)
        .cornerRadius(UIConstant.CornerRadius.medium8)
    }

    @ViewBuilder
    private func virtualVisitView() -> some View {
        if viewModel.virtualVisitSectionState.isVisible {
            VStack(alignment: .leading, spacing: UIConstant.Spacing.large16) {
                Text("MainView.VirtualVisit.Title")
                    .font(.dxH4)
                    .foregroundColor(.dxTextPrimary)
                Text("MainView.VirtualVisit.Subtitle")
                    .font(.dxBody1)
                    .foregroundColor(.dxTextPrimary)
                virtualPracticeRegionPicker()
                Button(action: {
                    viewModel.startVirtualVisitFlow()
                }, label: {
                    Text("MainView.VirtualVisit.Button.ScheduleAVisit")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(RectangleButtonStyle.primary)
                .disabled(viewModel.selectedRegion == nil || viewModel.virtualVisitSectionState.viewState != .loaded)
            }
        }
    }
    
    @ViewBuilder
    private func sdkVersionView() -> some View {
        Text("MainView.SdkVersion.Info")
            .font(.dxH4)
            .foregroundColor(.dxTextPrimary)
    }

    @ViewBuilder
    private func virtualPracticeRegionPicker() -> some View {
        switch viewModel.virtualVisitSectionState.viewState {
        case .loading, .loaded:
            CustomPickerField(
                "VirtualVisit.Field.Region.Title",
                text: $viewModel.selectedRegionName,
                isLoading: $viewModel.virtualVisitSectionState.isLoading,
                isPresented: $viewModel.isRegionPickerPresented,
                presentingView: CustomPickerList(
                    title: "VirtualVisit.Field.Regions.Title",
                    instructions: "VirtualVisit.Field.Regions.Message",
                    entries: viewModel.virtualVisitSectionState.openRegions,
                    isPresented: $viewModel.isRegionPickerPresented,
                    selectedEntry: $viewModel.selectedRegion
                )
            )
        case .error:
            Text("Regions.Error.FailedToLoadRegions")
                .font(.dxBody1)
                .foregroundColor(Color.dxAlert)
        }
    }
}

#Preview {
    MainView()
}
