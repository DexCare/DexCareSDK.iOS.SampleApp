//
//  Color+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-05.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation
import SwiftUI

public extension Color {
    /// Returns a lighter version of the given color
    func lighter(by percentage: CGFloat = 20.0) -> Color {
        adjust(by: abs(percentage))
    }

    /// Returns a darker version of the given color
    func darker(by percentage: CGFloat = 20.0) -> Color {
        adjust(by: -1 * abs(percentage))
    }

    // MARK: Private

    /// Returns a color where the RGB values are changed by the given percentage
    func adjust(by percentage: CGFloat) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        if UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return Color(UIColor(
                red: min(red + percentage / 100, 1.0),
                green: min(green + percentage / 100, 1.0),
                blue: min(blue + percentage / 100, 1.0),
                alpha: alpha
            ))
        } else {
            return self
        }
    }
}
