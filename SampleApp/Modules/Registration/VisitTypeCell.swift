//
//  VisitTypeCell.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-09.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import SwiftUI

/// View representing a visit type.
struct VisitTypeCell: View {
    // MARK: Properties

    private let visitType: ProviderVisitType
    private let action: () -> Void

    // MARK: Lifecycle

    init(visitType: ProviderVisitType, action: @escaping () -> Void) {
        self.visitType = visitType
        self.action = action
    }

    // MARK: Body

    var body: some View {
        Button(action: action, label: {
            HStack(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/, spacing: 0) {
                imageView()
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
                Text(visitType.name)
                    .font(.dxSubtitle1)
                    .foregroundColor(.dxTextPrimary)
                    .multilineTextAlignment(.leading)
                Text(visitType.description ?? "")
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

    private func imageView() -> some View {
        ZStack {
            Color.dxAccent
            Image(systemName: systemImageName())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .padding(UIConstant.Spacing.large16)
                .foregroundColor(.dxTextLight)
        }
    }

    // MARK: Private Methods

    private func systemImageName() -> String {
        guard let shortName = visitType.shortName else {
            return "cross"
        }
        switch shortName {
        case .illness:
            return "facemask"
        case .wellness:
            return "cross.circle"
        case .virtual:
            return "tv"
        case .followUp:
            return "stethoscope"
        case .newPatient:
            return "person.fill.badge.plus"
        case .wellChild:
            return "figure.and.child.holdinghands"
        case .adultPhysical:
            return "figure.wave"
        case .childPhysical:
            return "figure.and.child.holdinghands"
        case .newSymptoms:
            return "pencil.and.list.clipboard"
        default:
            return "cross"
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            VisitTypeCell(
                visitType: .init(
                    visitTypeId: "1",
                    name: "New Visit",
                    shortName: .newPatient,
                    description: "Lorem Ipsum Det Malar Put Put"
                ),
                action: {}
            )
            VisitTypeCell(
                visitType: .init(
                    visitTypeId: "1",
                    name: "Child Visit",
                    shortName: .childPhysical,
                    description: "Lorem Ipsum Det Malar Put Put"
                ),
                action: {}
            )
            Spacer()
        }
        .padding()
    }
}
