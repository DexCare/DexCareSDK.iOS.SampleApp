//
//  Transaction+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-15.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation
import SwiftUI

extension Transaction {
    /// Transaction where the animation are disabled
    static var disabledAnimationTransaction: Transaction {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        return transaction
    }
}
