//
//  Font+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-08.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation
import SwiftUI

/// Apps fonts / design system.
extension Font {
    private static let regularFont = "Lato-Regular"
    private static let boldFont = "Lato-Bold"

    static let dxH1: Font = .custom(boldFont, size: 36, relativeTo: .largeTitle)
    static let dxH2: Font = .custom(boldFont, size: 28, relativeTo: .title)
    static let dxH3: Font = .custom(boldFont, size: 24, relativeTo: .title2)
    static let dxH4: Font = .custom(boldFont, size: 20, relativeTo: .title3)
    static let dxH5: Font = .custom(boldFont, size: 18, relativeTo: .title3)

    static let dxSubtitle1: Font = .custom(boldFont, size: 16, relativeTo: .subheadline)
    static let dxSubtitle2: Font = .custom(boldFont, size: 14, relativeTo: .subheadline)

    static let dxBody1: Font = .custom(regularFont, size: 16, relativeTo: .body)
    static let dxBody2: Font = .custom(regularFont, size: 14, relativeTo: .body)

    static let dxCaption: Font = .custom(regularFont, size: 12, relativeTo: .caption)

    static let dxActionLarge: Font = .custom(boldFont, size: 16, relativeTo: .callout)
    static let dxActionMedium: Font = .custom(boldFont, size: 14, relativeTo: .callout)
}

extension Font {
    /// Utility method used to list all the fonts available on the device.
    /// This is useful to find the exact name of the font you added to your project.
    static func listAllFonts() {
        #if DEBUG
            for family in UIFont.familyNames {
                print("Font family name: \(family)")
                for font in UIFont.fontNames(forFamilyName: family) {
                    print("  Font name: \(font)")
                }
            }
        #endif
    }
}
