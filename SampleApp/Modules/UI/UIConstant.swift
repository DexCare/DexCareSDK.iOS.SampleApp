//
//  UIConstant.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-08.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

/// List of UI constants used by the SampleApp
enum UIConstant {
    enum BorderWidth {
        static let default2: CGFloat = 2
    }

    enum CornerRadius {
        static let small4: CGFloat = 4
        static let medium8: CGFloat = 8
    }

    enum Spacing {
        static let xSmall4: CGFloat = 4
        static let small8: CGFloat = 8
        static let medium12: CGFloat = 12
        static let large16: CGFloat = 16
        static let xlarge20: CGFloat = 20
        static let xxLarge24: CGFloat = 24
        static let xxxLarge32: CGFloat = 32
        static let xxxxLarge40: CGFloat = 40

        static let defaultListCell16: CGFloat = 16 // Default spacing between cells
        static let defaultSide16: CGFloat = 16 // Default spacing on the side of screens
        static let defaultScrollViewTop16: CGFloat = 16 // Default spacing at the top of a scroll view
        static let defaultScrollViewBotton40: CGFloat = 40 // Default spacing at the bottom of a scroll view
    }
}
