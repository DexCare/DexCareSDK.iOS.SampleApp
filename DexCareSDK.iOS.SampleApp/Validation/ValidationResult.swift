//  Copyright © 2020 DexCare. All rights reserved.

import Foundation

public enum ValidationResult {
    case valid
    case invalid([ValidationError])
    
    public var isValid: Bool {
        return self == .valid
    }
    
    public var messageText: String? {
        switch self {
            case .valid:
                return nil
            case .invalid(let errors):
                return errors.first?.localizedErrorMessage
        }
    }
    
    public func merge(with result: ValidationResult) -> ValidationResult {
        switch self {
            case .valid: return result
            case .invalid(let errors):
                switch result {
                    case .valid:
                        return self
                    case .invalid(let errorsAnother):
                        return .invalid([errors, errorsAnother].flatMap { $0 })
            }
        }
    }
    
    public func merge(with results: [ValidationResult]) -> ValidationResult {
        return results.reduce(self) { return $0.merge(with: $1) }
    }
    
    public static func merge(results: [ValidationResult]) -> ValidationResult {
        return ValidationResult.valid.merge(with: results)
    }
}

extension ValidationResult: Equatable {}
public func ==(lhs: ValidationResult, rhs: ValidationResult) -> Bool {
    switch (lhs, rhs) {
        case (.valid, .valid): return true
        case (.invalid, .invalid): return true
        default: return false
    }
}

public struct ValidationError: Error {
    
    let localizedErrorMessage: String
    let localizedRecoverySuggestion: String?
    
    public init(localizedErrorMessage: String, localizedRecoverySuggestion: String?) {
        self.localizedErrorMessage = localizedErrorMessage
        self.localizedRecoverySuggestion = localizedRecoverySuggestion
    }
}


public struct LengthLimitedString: Equatable, Codable {
    public let maxLength: Int
    public private(set) var value: String = ""
    
    public init(maxLength: Int, value: String = "") {
        self.maxLength = maxLength
        self.update(with: value)
    }
    
    public mutating func update(with newValue: String?) {
        guard let newValue = newValue else {
            value = ""
            return
        }
        if newValue.count > maxLength {
            let endIndex = newValue.index(newValue.startIndex, offsetBy: maxLength)
            let subString = newValue[..<endIndex]
            value = String(subString)
        }
        else {
            value = newValue
        }
    }
}

