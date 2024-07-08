//
//  RulesValidator.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-24.
//

import Foundation

enum RulesValidator {
    /// Utility method that allow you to run a series of validation method and exit if one of them
    /// fails (aka returns a validation message)
    static func validate(_ validations: [() -> String?]) -> String? {
        for validation in validations {
            if let errorMessage = validation() {
                return errorMessage
            }
        }
        return nil
    }
}
