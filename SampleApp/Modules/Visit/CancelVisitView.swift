//
//  CancelVisitView.swift
//  SampleApp
//
//  Created by Alex Maslov on 2024-09-23.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import SwiftUI

struct CancelVisitView: View {
    let reasons: [CancelReason]
    @State private var selectedReason: CancelReason
    let onReasonSelected: (CancelReason) -> Void

    init(reasons: [CancelReason], onReasonSelected: @escaping (CancelReason) -> Void) {
        self.reasons = reasons
        self.selectedReason = reasons[0]
        self.onReasonSelected = onReasonSelected
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("CancelVisit.Subtitle")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Picker("", selection: $selectedReason) {
                ForEach(reasons, id: \.code) { reason in
                    Text(reason.displayText).tag(reason)
                }
            }
            .frame(maxWidth: .infinity)
            .primaryPickerStyle()

            Button(action: {
                onReasonSelected(selectedReason)
            }) {
                Text("CancelVisit.Submit")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(RectangleButtonStyle.primary)

            Spacer()
        }
        .padding()
    }
}

struct CancelVisitView_Previews: PreviewProvider {
    static var mocks: [CancelReason] = {
        let jsonString = """
        [
          {
            "clientText": "High wait time",
            "stringCode": "VisitCancelReasonValue.highWaitTime"
          },
          {
            "clientText": "Found another care option",
            "stringCode": "VisitCancelReasonValue.foundAnotherCareOption"
          },
          {
            "clientText": "Appointment conflict",
            "stringCode": "VisitCancelReasonValue.appointmentConflict"
          },
          {
            "clientText": "Work conflict",
            "stringCode": "VisitCancelReasonValue.workConflict"
          },
          {
            "clientText": "Out of town",
            "stringCode": "VisitCancelReasonValue.outOfTown"
          },
          {
            "clientText": "Personal reason",
            "stringCode": "VisitCancelReasonValue.personalReason"
          }
        ]
        """

        // Convert the JSON string to Data
        let jsonData = jsonString.data(using: .utf8)!

        // Decode the JSON data into an array of CancelReason
        let reasons = try! JSONDecoder().decode([CancelReason].self, from: jsonData)

        return reasons
    }()

    static var previews: some View {
        CancelVisitView(reasons: mocks, onReasonSelected: { _ in })
    }
}
