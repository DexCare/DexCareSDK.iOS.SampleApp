//
//  CustomPickerList.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-15.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import SwiftUI

/// List of options that can be displayed in a bottom sheet.
struct CustomPickerList<T: Identifiable>: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    // MARK: Properties

    private var title: LocalizedStringKey
    private var instructions: LocalizedStringKey?
    private var entries: [CustomPickerEntry<T>]
    private var isPresented: Binding<Bool>
    private var selectedEntry: Binding<T?>

    // MARK: Body

    var body: some View {
        NavigationStack {
            listView()
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: cancelButton())
        }
    }

    // MARK: Lifecycle

    init(
        title: LocalizedStringKey,
        instructions: LocalizedStringKey? = nil,
        entries: [CustomPickerEntry<T>],
        isPresented: Binding<Bool>,
        selectedEntry: Binding<T?>
    ) {
        self.title = title
        self.instructions = instructions
        self.entries = entries
        self.isPresented = isPresented
        self.selectedEntry = selectedEntry
    }

    // MARK: Private Views

    private func cancelButton() -> some View {
        Button(action: {
            isPresented.wrappedValue = false
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.dxNavigationbarForeground)
        }
    }

    private func listView() -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if let instructions {
                    Text(instructions)
                        .font(.dxBody1)
                        .foregroundColor(.dxTextSecondary)
                    Divider()
                        .padding(.top, UIConstant.Spacing.defaultListCell16)
                }
                ForEach(entries, id: \.id) { entry in
                    CustomPickerCell(
                        entry: entry,
                        selectedEntry: selectedEntry.wrappedValue
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedEntry.wrappedValue = entry.item
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .padding(.top, UIConstant.Spacing.defaultScrollViewTop16)
            .padding(.horizontal, UIConstant.Spacing.defaultSide16)
            .padding(.bottom, UIConstant.Spacing.defaultScrollViewBotton40)
        }
    }
}

#Preview {
    CustomPickerList(
        title: "RegistrationStep.Field.Gender.Title",
        instructions: "RegistrationStep.Field.Gender.Instructions",
        entries: [
            .init(title: "Male", item: Gender.male),
            .init(title: "Female", item: Gender.female),
            .init(title: "Other", item: Gender.other),
        ],
        isPresented: .constant(true),
        selectedEntry: .constant(.other)
    )
}
