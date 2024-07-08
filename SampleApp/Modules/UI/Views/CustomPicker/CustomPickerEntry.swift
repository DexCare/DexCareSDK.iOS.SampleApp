//
//  CustomPickerEntry.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-15.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

/// Content used by the `CustomPickerCell` and the `CustomPickerList`.
struct CustomPickerEntry<T: Identifiable> {
    var id: T.ID {
        item.id
    }

    private(set) var item: T
    private(set) var title: String
    private(set) var subtitle: String?

    init(title: String, subtitle: String? = nil, item: T) {
        self.title = title
        self.subtitle = subtitle
        self.item = item
    }
}
