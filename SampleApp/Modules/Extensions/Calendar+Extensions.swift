//
//  Calendar+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-05-02.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

public extension Calendar {
    /// Creates a calendar for the given time zone.
    static func calendar(for timezone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone
        return calendar
    }
}
