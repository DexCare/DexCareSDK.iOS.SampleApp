//
//  Date+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-06.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

extension Date {
    // MARK: Lifecycle

    /// Convenience initializer to make it easier to create dates in tests and previews.
    /// Default format is "yyyy-MM-dd" (For example, 1980-12-24) However, you can define your own format.
    init(dateString: String, format: String = "yyyy-MM-dd") {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = format

        guard let date = dateStringFormatter.date(from: dateString) else {
            assertionFailure("Failed to create date for string \(dateString)")
            self.init()
            return
        }
        self.init(timeInterval: 0, since: date)
    }

    /// Convenience initializer to make it easier to create date with times in tests and previews.
    /// Default format is "yyyy-MM-dd HH:mm" (For example, 1980-12-24 15:31) However, you can define your own format.
    init(dateTimeString: String, format: String = "yyyy-MM-dd HH:mm", timeZone: TimeZone = TimeZone.current) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = format
        dateStringFormatter.timeZone = timeZone

        guard let date = dateStringFormatter.date(from: dateTimeString) else {
            assertionFailure("Failed to create date for string \(dateTimeString)")
            self.init()
            return
        }
        self.init(timeInterval: 0, since: date)
    }

    // MARK: Methods

    /// Adds the number of days to the current day.
    func addDays(_ days: Int, calendar: Calendar = Calendar.current) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = days
        return calendar.date(byAdding: dateComponents, to: self)
    }

    /// Returns the start of day at the given timezone.
    func startOfDay(in timezone: TimeZone) -> Date {
        Calendar.calendar(for: timezone).startOfDay(for: self)
    }
}
