//
//  CustomPickerCell.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-15.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import SwiftUI

/// Cell used by the `CustomPickerList`
struct CustomPickerCell<T: Identifiable>: View {
    private var entry: CustomPickerEntry<T>
    private var selectedEntry: T?
    private var isSelected: Bool {
        entry.id == selectedEntry?.id
    }

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.defaultListCell16 / 2) {
            HStack(alignment: .center, spacing: UIConstant.Spacing.large16) {
                contentView()
                Spacer()
                checkView()
            }
            Divider()
        }
        .padding(.top, UIConstant.Spacing.defaultListCell16 / 2)
    }

    // MARK: Lifecycle

    init(entry: CustomPickerEntry<T>, selectedEntry: T?) {
        self.entry = entry
        self.selectedEntry = selectedEntry
    }

    // MARK: Private Views

    @ViewBuilder
    private func checkView() -> some View {
        if isSelected {
            Image(systemName: "checkmark")
                .foregroundColor(.dxAccent)
        }
    }

    private func contentView() -> some View {
        VStack(alignment: .leading, spacing: UIConstant.Spacing.xSmall4) {
            Text(entry.title)
                .font(.dxSubtitle1)
                .foregroundColor(.dxTextPrimary)
                .multilineTextAlignment(.leading)
            if let subtitle = entry.subtitle {
                Text(subtitle)
                    .font(.dxCaption)
                    .foregroundColor(.dxTextSecondary)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        CustomPickerCell(
            entry: CustomPickerEntry(
                title: "Washington",
                subtitle: "$50",
                item: "1"
            ),
            selectedEntry: "1"
        )
        CustomPickerCell(
            entry: CustomPickerEntry(
                title: "Washington",
                subtitle: "$50",
                item: "1"
            ),
            selectedEntry: "2"
        )
        CustomPickerCell(
            entry: CustomPickerEntry(
                title: "Male",
                item: Gender.male
            ),
            selectedEntry: Gender.female
        )
        CustomPickerCell(
            entry: CustomPickerEntry(
                title: "Female",
                item: Gender.female
            ),
            selectedEntry: Gender.female
        )
    }
    .padding(.horizontal, UIConstant.Spacing.defaultSide16)
}
