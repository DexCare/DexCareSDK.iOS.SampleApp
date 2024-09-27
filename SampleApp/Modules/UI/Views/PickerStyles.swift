//
//  PickerStyles.swift
//  SampleApp
//
//  Created by Alex Maslov on 2024-09-23.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation
import SwiftUI

import SwiftUI

struct PrimaryPickerModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled

    func body(content: Content) -> some View {
        content
            .font(.dxActionLarge)
            .foregroundColor(isEnabled ? .dxButtonSecondary : .dxTextLight)
            .padding(.all, UIConstant.Spacing.small8)
            .background(
                RoundedRectangle(cornerRadius: UIConstant.CornerRadius.medium8, style: .continuous)
                    .fill(isEnabled ? .dxBackgroundPrimary : .dxButtonDisabled)
            )
            .tint(.dxButtonSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: UIConstant.CornerRadius.medium8, style: .continuous)
                    .strokeBorder(isEnabled ? .dxButtonSecondary : .dxButtonDisabled, lineWidth: UIConstant.BorderWidth.default2)
            )
    }
}

// MARK: - View Extension

extension View {
    func primaryPickerStyle() -> some View {
        self.modifier(PrimaryPickerModifier())
    }
}

#Preview {
    VStack {
        Picker("Options", selection: .constant(1)) {
            Text("Option 1").tag(1)
            Text("Option 2").tag(2)
            Text("Option 3").tag(3)
        }
        .primaryPickerStyle()

        Picker("Options Disabled", selection: .constant(1)) {
            Text("Option 1").tag(1)
            Text("Option 2").tag(2)
            Text("Option 3").tag(3)
        }
        .primaryPickerStyle()
        .disabled(true)
    }
    .padding()
}
