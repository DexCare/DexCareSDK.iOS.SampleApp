//
//  RectangleButtonStyle.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-08.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: ButtonStateColor

/// Defines the color of a button through it's different states.
struct ButtonStateColor {
    let normal: Color
    let pressed: Color
    let disabled: Color

    /// Returns the color of the button component based on the state
    ///
    /// - Parameters:
    ///   - isEnabled: Indicates if the button is enabled or not
    ///   - isPressed: Indicates if the button is pressed or not
    func color(isEnabled: Bool, isPressed: Bool) -> Color {
        if !isEnabled {
            return disabled
        }

        return isPressed ? pressed : normal
    }

    init(normal: Color, pressed: Color, disabled: Color) {
        self.normal = normal
        self.pressed = pressed
        self.disabled = disabled
    }
}

// MARK: RectangleButtonConfig

/// Configuration for a rectangle button style
struct RectangleButtonConfig {
    let font: Font
    let foregroundColor: ButtonStateColor
    let backgroundColor: ButtonStateColor
    let borderColor: ButtonStateColor
    let borderWidth: CGFloat
    let padding: EdgeInsets
    let cornerRadius: CGFloat

    init(
        font: Font = .callout,
        foreground: ButtonStateColor,
        background: ButtonStateColor,
        border: ButtonStateColor,
        borderWidth: CGFloat,
        padding: EdgeInsets,
        cornerRadius: CGFloat
    ) {
        self.font = font
        foregroundColor = foreground
        backgroundColor = background
        borderColor = border
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
}

// MARK: RectangleButtonStyle

/// Button style that allows you to create a rectangle  button with different layouts.
struct RectangleButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    private let config: RectangleButtonConfig

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(config.font)
            .foregroundColor(config.foregroundColor.color(isEnabled: isEnabled, isPressed: configuration.isPressed))
            .padding(config.padding)
            .background(
                RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous)
                    .strokeBorder(config.borderColor.color(isEnabled: isEnabled, isPressed: configuration.isPressed), lineWidth: config.borderWidth)
            )
            .background(
                RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous)
                    .fill(config.backgroundColor.color(isEnabled: isEnabled, isPressed: configuration.isPressed))
            )
    }

    init(config: RectangleButtonConfig) {
        self.config = config
    }
}

// MARK: RectangleButtonStyle Default Styles

extension RectangleButtonStyle {
    /// Primary Button Style
    static let primary = RectangleButtonStyle(config: .init(
        font: .dxActionLarge,
        foreground: .init(
            normal: .dxTextLight,
            pressed: .dxTextLight,
            disabled: .dxTextLight
        ),
        background: .init(
            normal: .dxButtonPrimary,
            pressed: .dxButtonPrimary.lighter(),
            disabled: .dxButtonDisabled
        ),
        border: .init(
            normal: .dxButtonPrimary,
            pressed: .dxButtonPrimary.lighter(),
            disabled: .dxButtonDisabled
        ),
        borderWidth: 0,
        padding: EdgeInsets(all: UIConstant.Spacing.large16),
        cornerRadius: UIConstant.CornerRadius.medium8
    ))

    /// Secondary Button Style
    static let secondary = RectangleButtonStyle(config: .init(
        font: .dxActionLarge,
        foreground: .init(
            normal: .dxButtonSecondary,
            pressed: .dxTextLight,
            disabled: .dxTextLight
        ),
        background: .init(
            normal: .dxBackgroundPrimary,
            pressed: .dxButtonSecondary.lighter(),
            disabled: .dxButtonDisabled
        ),
        border: .init(
            normal: .dxButtonSecondary,
            pressed: .dxButtonSecondary.lighter(),
            disabled: .dxButtonDisabled
        ),
        borderWidth: UIConstant.BorderWidth.default2,
        padding: EdgeInsets(all: UIConstant.Spacing.large16),
        cornerRadius: UIConstant.CornerRadius.medium8
    ))
    /// Tertiary Button Style
    static let tertiary = RectangleButtonStyle(config: .init(
        font: .dxActionLarge,
        foreground: .init(
            normal: .dxButtonTertiary,
            pressed: .dxButtonTertiary.lighter(),
            disabled: .dxButtonDisabled
        ),
        background: .init(
            normal: .clear,
            pressed: .clear,
            disabled: .clear
        ),
        border: .init(
            normal: .clear,
            pressed: .clear,
            disabled: .clear
        ),
        borderWidth: 0,
        padding: EdgeInsets(all: UIConstant.Spacing.small8),
        cornerRadius: 0
    ))
}

#Preview {
    VStack {
        // Primary
        Button {} label: {
            Text("Z.Preview.Button.Primary")
        }
        .buttonStyle(RectangleButtonStyle.primary)
        Button {} label: {
            Text("Z.Preview.Button.Primary.Disabled")
        }
        .buttonStyle(RectangleButtonStyle.primary)
        .disabled(true)

        // Secondary
        Button {} label: {
            Text("Z.Preview.Button.Secondary")
        }
        .buttonStyle(RectangleButtonStyle.secondary)
        Button {} label: {
            Text("Z.Preview.Button.Secondary.Disabled")
        }
        .buttonStyle(RectangleButtonStyle.secondary)
        .disabled(true)

        // Secondary
        Button {} label: {
            Text("Z.Preview.Button.Tertiary")
        }
        .buttonStyle(RectangleButtonStyle.secondary)
        Button {} label: {
            Text("Z.Preview.Button.Tertiary.Disabled")
        }
        .buttonStyle(RectangleButtonStyle.secondary)
        .disabled(true)
    }
}
