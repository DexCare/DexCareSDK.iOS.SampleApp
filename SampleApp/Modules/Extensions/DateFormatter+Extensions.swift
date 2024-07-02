//
//  DateFormatter+Extensions.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-16.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

extension DateFormatter {
    /// Example, "Aug 31, 2021"
    static let birthdate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Date {
    /// Example, "Aug 31, 2021"
    func birthdateString() -> String {
        DateFormatter.birthdate.string(from: self)
    }
}
