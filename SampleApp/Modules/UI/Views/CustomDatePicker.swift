//
//  CustomDatePicker.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-16.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// A picker view that can be displayed in a bottom sheet.
struct DatePickerView: View {
    // MARK: Properties

    @State var selectedDate: Date = .init()
    @Binding var externalSelectedDate: Date?
    @Binding var isPresented: Bool

    // MARK: Body

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("DatePicker.Title"))
            .navigationBarItems(trailing: Button("Common.Button.Done") {
                isPresented = false
            })
        }
        .onChange(of: selectedDate) { newValue in
            externalSelectedDate = newValue
        }
    }

    // MARK: Lifecycle

    init(selectedDate: Binding<Date?>, isPresented: Binding<Bool>) {
        _externalSelectedDate = selectedDate
        _isPresented = isPresented
        self.selectedDate = selectedDate.wrappedValue ?? Date()
    }
}

#Preview {
    DatePickerView(selectedDate: .constant(Date()), isPresented: .constant(true))
}
