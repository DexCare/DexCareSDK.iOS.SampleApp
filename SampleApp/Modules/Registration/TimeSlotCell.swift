//
//  TimeSlotCell.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-06.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import SwiftUI

/// Cell representing a given appointment time slot.
struct TimeSlotCell: View {
    // MARK: Properties

    @Binding var selectedTimeSlot: TimeSlot?
    private(set) var time: String
    private let timeSlot: TimeSlot
    private let timeZone: TimeZone
    private var isSelected: Bool {
        selectedTimeSlot == timeSlot
    }

    lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    // MARK: Body

    var body: some View {
        Text(time)
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(isSelected ? .dxTextLight : .dxTextPrimary)
            .padding(UIConstant.Spacing.small8)
            .overlay(
                RoundedRectangle(cornerRadius: UIConstant.CornerRadius.small4)
                    .stroke(
                        .dxTextfieldBackground,
                        lineWidth: UIConstant.BorderWidth.default2
                    )
            )
            .background(isSelected ? Color.dxAccent : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: UIConstant.CornerRadius.small4))
            .contentShape(RoundedRectangle(cornerRadius: UIConstant.CornerRadius.small4))
            .onTapGesture {
                if isSelected {
                    selectedTimeSlot = nil
                } else {
                    selectedTimeSlot = timeSlot
                }
            }
    }

    // MARK: Lifecycle

    init(
        timeSlot: TimeSlot,

        timeZone: TimeZone,
        selectedTimeSlot: Binding<TimeSlot?>
    ) {
        self.timeSlot = timeSlot
        self.timeZone = timeZone
        _selectedTimeSlot = selectedTimeSlot
        time = ""
        time = timeFormatter.string(from: timeSlot.slotDateTime)
    }
}

#Preview {
    let tokyoTimeZone = TimeZone(identifier: "Asia/Tokyo")!
    let may_5_at_9am = TimeSlot(
        slotId: "1",
        providerNationalId: "1",
        providerId: "1",
        departmentId: "1",
        departmentIdentifier: "1",
        slotType: "type",
        visitTypeId: "1",
        durationInMin: 60,
        slotDateTime: Date(
            dateTimeString: "2023-05-05 9:00",
            timeZone: tokyoTimeZone
        )
    )

    let may_5_at_10am = TimeSlot(
        slotId: "1",
        providerNationalId: "1",
        providerId: "1",
        departmentId: "1",
        departmentIdentifier: "1",
        slotType: "type",
        visitTypeId: "1",
        durationInMin: 60,
        slotDateTime: Date(
            dateTimeString: "2023-05-05 10:00",
            timeZone: tokyoTimeZone
        )
    )
    let may_5_at_11am = TimeSlot(
        slotId: "1",
        providerNationalId: "1",
        providerId: "1",
        departmentId: "1",
        departmentIdentifier: "1",
        slotType: "type",
        visitTypeId: "1",
        durationInMin: 60,
        slotDateTime: Date(
            dateTimeString: "2023-05-05 11:00",
            timeZone: tokyoTimeZone
        )
    )

    return VStack {
        HStack {
            TimeSlotCell(
                timeSlot: may_5_at_9am,
                timeZone: tokyoTimeZone,
                selectedTimeSlot: .constant(may_5_at_10am)
            )
            TimeSlotCell(
                timeSlot: may_5_at_10am,
                timeZone: tokyoTimeZone,
                selectedTimeSlot: .constant(may_5_at_10am)
            )
            TimeSlotCell(
                timeSlot: may_5_at_11am,
                timeZone: tokyoTimeZone,
                selectedTimeSlot: .constant(may_5_at_10am)
            )
        }
    }
    .padding()
}
