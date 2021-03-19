//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import DexcareiOSSDK
protocol Validator {
    
    func checkForValidationErrors(_: String) -> ValidationResult
}

protocol DateValidator {
    
    func checkForValidationErrors(_: Date) -> ValidationResult
}

extension Validator {
    func checkForValidationErrors(_ value: String?, required: Bool = true) -> ValidationResult {
        let value = value ?? ""
        if !required && value == "" {
            return .valid
        }
        return checkForValidationErrors(value)
    }
}


// MARK: - Convenience struct

struct Validators {
    
    static let NonEmptyTextValidator = ClosureValidator { value in
        if value.trimmingCharacters(in: .whitespaces).isEmpty {
            return .invalid([ValidationError(localizedErrorMessage: localizedString("NonEmptyMessage"), localizedRecoverySuggestion: localizedString("NonEmptyRecovery"))])
        }
        
        return .valid
    }
    
    static let EmailAddress = EmailAddressValidator()
    static let PhoneNumber = PhoneNumberValidator()
    static let StateCode = StateCodeValidator()
    static let ZipCode = ZipCodeValidator()
    static let SSNLastFour = LastFourSSNValidator()
    static let minimumAge = MinimumAgeYearValidator(minimum: 18)
    static let minimumAgeChild = MinimumAgeMonthValidator(minimum: 18)
    static let dateInPast = BirthDateInPastValidator()
    static let alphaAndSpacesCharacterSet: CharacterSet = {
        var characters = CharacterSet()
        characters.formUnion(.letters)
        characters.formUnion(.whitespaces)
        characters.insert(charactersIn: "-")
        return characters
    }()
    static let alphaAndSpacesCharactersOnly = CompositeValidator(validators: [ CharacterSetValidator(characterSet: alphaAndSpacesCharacterSet), Validators.NonEmptyTextValidator])
    
}

// MARK: - Email Validation

/**
 Validates email addresses with the following criteria
 - min length = 6
 - max length = 254
 - checks for invalid email characters
 */

private enum EmailConstants {
    static let maxLength = 254
    static let validCharacterSet: CharacterSet = {
        let alphanumerics = CharacterSet.alphanumerics
        let punctuation = CharacterSet(charactersIn: "!#$%&'*+-/=?^_`{|}~.@")
        return alphanumerics.union(punctuation)
    }()
}

struct EmailAddressValidator: Validator {
    
    private let validators: Validator
    
    init() {
        validators = CompositeValidator(validators: [MaximumLengthValidator(length: EmailConstants.maxLength),
                                                     emailFormatValidator])
    }
    
    private let emailFormatValidator = ClosureValidator { value in
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,64}" // DexcareSDK.EmailValidator.EMAIL_VALIDATION_REGEX
        
        if !NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: value) {
            return .invalid([ValidationError(localizedErrorMessage: localizedString("ValidEmailMessage"),
                                             localizedRecoverySuggestion: localizedString("ValidEmailRecovery"))])
        }
        
        return .valid
    }
    
    func checkForValidationErrors(_ value: String) -> ValidationResult {
        return validators.checkForValidationErrors(value)
    }
}


// MARK: - Phone Validation

/**
 Validates US/Canadian centric phone numbers... could be extended to handle international numbers but not right now
 - min length = 10
 - max length = 14
 - checks for valid US phone characters
 
 Valid Examples:
 - (123) 123-1234
 - 123 123 1234
 - 123.123.1234
 - 1231231234
 */
private enum PhoneConstants {
    static let minLength = 10
    static let maxLength = 14
    static let validCharacterSet: CharacterSet = {
        let numbers = CharacterSet.decimalDigits
        let punctuation = CharacterSet(charactersIn: "()- .")
        return numbers.union(punctuation)
    }()
}

struct PhoneNumberValidator: Validator {
    
    private let validators: Validator
    
    init() {
        validators = CompositeValidator(validators: [phoneFormatValidator,
                                                     MinimumLengthValidator(length: PhoneConstants.minLength),
                                                     MaximumLengthValidator(length: PhoneConstants.maxLength)
        ])
    }
    
    // https://jira.dig.engineering/browse/MOB-4875
    //  Epic Requirements:
    //       - 10 digit phone numbers
    //             - Area code (first 3 digits of 10 digit phone number) cannot begin with 0 or 1
    //             - Second digit of area code cannot be 9
    //             - Fourth digit (the digit after area code) cannot be a 0 or 1
    //       - 11 digit numbers *only* if they begin with 1 and the rest follows above requirements
    //   RegEx used by web: /^\(?(?:[2-9][0-8]\d)\)?[- ]?(?:[2-9]\d{2})[-]?(?:\d{4})$/
    //
    //   We handle only 10 digit numbers until we update the autoformatting to handle 11 digit numbers
    private let phoneFormatValidator = ClosureValidator { value in
        let phoneRegex = PhoneValidator.PHONE_VALIDATION_REGEX
        
        var number = value.removingNonNumericCharacters()
        
        let areaCodeFirstDigit = number[safe: number.startIndex] // the first digit
        if areaCodeFirstDigit == "0" || areaCodeFirstDigit == "1" {
            return .invalid([ValidationError(localizedErrorMessage: localizedString("InvalidPhoneAreaCodeCannotBeginWith0Or1"),
                                             localizedRecoverySuggestion: nil)])
        }
        
        if number.count > 1 {
            let areaCodeSecondDigit = number[number.index(number.startIndex, offsetBy: 1)] // the second digit
            if areaCodeSecondDigit == "9" {
                return .invalid([ValidationError(localizedErrorMessage: localizedString("InvalidPhoneAreaCodeSecondDigitCannotBe9"),
                                                 localizedRecoverySuggestion: nil)])
            }
        }
        
        if number.count > 3{
            let firstDigitAfterAreaCode = number[number.index(number.startIndex, offsetBy: 3)] // the fourth digit
            if firstDigitAfterAreaCode == "0" || firstDigitAfterAreaCode == "1" {
                return .invalid([ValidationError(localizedErrorMessage: localizedString("InvalidPhoneFirstDigitAfterAreaCodeCannotBeginWith0Or1"), localizedRecoverySuggestion: nil)])
            }
        }
        
        
        if !NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: value) {
            return .invalid([ValidationError(localizedErrorMessage: localizedString("ValidPhoneMessage"),
                                             localizedRecoverySuggestion: localizedString("ValidPhoneRecovery"))])
        }
        
        return .valid
    }
    
    func checkForValidationErrors(_ value: String) -> ValidationResult {
        return validators.checkForValidationErrors(value)
    }
}

// MARK: - Internal Validators

struct ClosureValidator: Validator {
    
    let checkForValidationErrors: (String) -> ValidationResult
    
    init(checkForValidationErrors: @escaping (String) -> ValidationResult) {
        self.checkForValidationErrors = checkForValidationErrors
    }
    
    func checkForValidationErrors(_ value: String) -> ValidationResult {
        return checkForValidationErrors(value)
    }
}

struct CompositeValidator: Validator {
    
    private let validators: [Validator]
    
    init(validators: [Validator]) {
        self.validators = validators
    }
    
    func checkForValidationErrors(_ value: String) -> ValidationResult {
        let results = validators.compactMap { $0.checkForValidationErrors(value) }
        return ValidationResult.merge(results: results)
    }
}

struct MinimumAgeYearValidator: DateValidator {
    
    private let minimum: Int
    
    init(minimum: Int) {
        self.minimum = minimum
    }
    
    func checkForValidationErrors(_ date: Date) -> ValidationResult {
        if date > Calendar.current.date(byAdding: .year, value: -minimum, to: Date())! {
            let errorMessage = String(format: localizedString("MinAgeMessage"), minimum)
            return .invalid([ValidationError(localizedErrorMessage: errorMessage, localizedRecoverySuggestion: nil)])
        }
        
        return .valid
    }
}
struct MinimumAgeMonthValidator: DateValidator {
    
    private let minimum: Int
    
    init(minimum: Int) {
        self.minimum = minimum
    }
    
    func checkForValidationErrors(_ date: Date) -> ValidationResult {
        if date > Calendar.current.date(byAdding: .month, value: -minimum, to: Date())! {
            let errorMessage = String(format: localizedString("MinAgeMonthMessage"), minimum)
            return .invalid([ValidationError(localizedErrorMessage: errorMessage, localizedRecoverySuggestion: nil)])
        }
        
        return .valid
    }
}

struct BirthDateInPastValidator: DateValidator {
    func checkForValidationErrors(_ date: Date) -> ValidationResult {
        if date >= Date() {
            let errorMessage = localizedString("InvalidBirthDateMessage")
            return .invalid([ValidationError(localizedErrorMessage: errorMessage, localizedRecoverySuggestion: nil)])
        }
        
        return .valid
    }
}

struct MinimumLengthValidator: Validator {
    
    private let length: Int
    
    init(length: Int) {
        self.length = length
    }
    
    func checkForValidationErrors(_ value: String) -> ValidationResult {
        if value.count < length {
            let errorMessage = String(format: localizedString("MinLengthMessage"), length)
            return .invalid([ValidationError(localizedErrorMessage: errorMessage, localizedRecoverySuggestion: nil)])
        }
        
        return .valid
    }
}

struct MaximumLengthValidator: Validator {
    
    private let length: Int
    
    init(length: Int) {
        self.length = length
    }
    
    func checkForValidationErrors(_ value: String) -> ValidationResult {
        if value.count > length {
            let errorMessage = String(format: localizedString("MaxLengthMessage"), length)
            return .invalid([ValidationError(localizedErrorMessage: errorMessage, localizedRecoverySuggestion: nil)])
        }
        
        return .valid
    }
}

struct CharacterSetValidator: Validator {
    
    enum Constants {
        static let invalidCharacterMessageSingular = localizedString("invalidCharacterMessageSingular")
        static let invalidCharacterMessagePlural = localizedString("invalidCharacterMessagePlural")
    }
    
    private let characterSet: CharacterSet
    
    init(characterSet: CharacterSet) {
        self.characterSet = characterSet
    }
    
    func checkForValidationErrors(_ value: String) -> ValidationResult {
        let invalidCharacters = value.components(separatedBy: characterSet).joined(separator: "")
        if invalidCharacters.isEmpty { return .valid }
        
        let invalidCharactersSet = Set(invalidCharacters)
        let invalidCharactersString = invalidCharactersSet.sorted().map { "\($0)" }.joined(separator: ", ")
        
        let errorFormat = invalidCharactersSet.count == 1 ? Constants.invalidCharacterMessageSingular
            : Constants.invalidCharacterMessagePlural
        
        let errorMessage = String(format: errorFormat, invalidCharactersString)
        return .invalid([ValidationError(localizedErrorMessage: errorMessage, localizedRecoverySuggestion: nil)])
    }
}


public struct StateCodeValidator: Validator {
    
    func checkForValidationErrors(_ stateCode: String) -> ValidationResult {
        if UnitedStatesISO3166SubdivisionsValidator.isValid(code: stateCode) {
            return .valid
        } else {
            return .invalid([ValidationError(
                localizedErrorMessage: localizedString("invalidStateCodeErrorMessage"),
                localizedRecoverySuggestion: nil)])
        }
    }
}

/**
 Validates US Zip Codes and can handle the basic 5 digit as well as the +4 option
 - min length = 5
 - max length = 9
 
 Valid Examples, without dash:
 - 123451234
 - 123453123
 
 Valid Examples, with dash:
 - 12345-1234
 - 12345
 */
public struct ZipCodeValidator: Validator {
    public let minLength: Int
    public let maxLength: Int
    public let characterSet: CharacterSet
    public let shortOnly: Bool
    public let dashRequired: Bool
    
    init(dashRequired: Bool = false, shortOnly: Bool = true) {
        minLength = 5
        maxLength = shortOnly ? 5 : (dashRequired ? 10 : 9)
        self.shortOnly = shortOnly
        self.dashRequired = dashRequired
        
        characterSet = {
            var characterSet = CharacterSet.decimalDigits
            if dashRequired {
                characterSet.insert("-")
            }
            return characterSet
        }()
    }
    
    func checkForValidationErrors(_ value: String) -> ValidationResult {
        let zipCodeRegex = shortOnly ? "^\\d{5}$" : (dashRequired ? "^\\d{5}(?:-\\d{4})?$" : "^\\d{5}|\\d{9}$")
        
        if !NSPredicate(format: "SELF MATCHES %@", zipCodeRegex).evaluate(with: value) {
            let longFormatHint = dashRequired ? "xxxxx-xxxx" : "xxxxxxxxx"
            let rawErrorMessage = localizedString("invalidZIPErrorMessage")
            let errorMessage = shortOnly ? localizedString("invalidZIP5Characters") : String(format: rawErrorMessage, longFormatHint)
            
            return .invalid([
                ValidationError(
                    localizedErrorMessage: errorMessage,
                    localizedRecoverySuggestion: localizedString("invalidZIPRecoveryMessage")
                )])
        }
        return .valid
    }
    
}

public struct LastFourSSNValidator: Validator {
    enum Constants {
        static let minLength = 4
        static let maxLength = 4
        static let validCharacterSet: CharacterSet = {
            return CharacterSet.decimalDigits
        }()
    }
    private let validators: Validator
    
    init() {
        validators = CompositeValidator(validators: [MinimumLengthValidator(length: Constants.minLength),
                                                     MaximumLengthValidator(length: Constants.maxLength), Validators.NonEmptyTextValidator])
    }
    
    func checkForValidationErrors(_ value: String) -> ValidationResult {
        return validators.checkForValidationErrors(value)
    }
}


func localizedString(_ key: String, comment: String = "") -> String {
    return NSLocalizedString(key, tableName: "Validation", bundle: Bundle.main, comment: comment)
}

extension String {
    public func removingNonNumericCharacters() -> String {
        return replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
}
