
//  Copyright © 2020 DexCare. All rights reserved.

import Foundation

public class PhoneFormatter {
    public enum Constants {
        public static let phoneNumberLength = 10
        static let areaCodeLength = 3
        static let prefixLength = 3
    }
    
    public static func formatPhoneNumber(_ phoneNumber: String) -> String {
        var index = 0
        let formattedString = NSMutableString()
        let length = phoneNumber.count
        
        if length > Constants.areaCodeLength {
            let startIndex = phoneNumber.index(phoneNumber.startIndex, offsetBy: index)
            let endIndex = phoneNumber.index(startIndex, offsetBy: Constants.areaCodeLength)
            let areaCode = phoneNumber[startIndex..<endIndex]
            formattedString.appendFormat("%@-", String(areaCode))
            index += Constants.areaCodeLength
        }
        if length - index > Constants.prefixLength {
            let startIndex = phoneNumber.index(phoneNumber.startIndex, offsetBy: index)
            let endIndex = phoneNumber.index(startIndex, offsetBy: Constants.prefixLength)
            let prefix = phoneNumber[startIndex..<endIndex]
            formattedString.appendFormat("%@-", String(prefix))
            index += Constants.prefixLength
        }
        
        let startIndex = phoneNumber.index(phoneNumber.startIndex, offsetBy: index)
        let remainder = phoneNumber.suffix(from: startIndex)
        formattedString.append(String(remainder))
        
        return formattedString as String
    }
    
    public static func removeNonDecimalCharacters(_ formattedPhoneNumber: String) -> String {
        var digits = ""
        
        for char in formattedPhoneNumber {
            if CharacterSet.decimalDigits.contains(char.unicodeScalars.first!) {
                digits += String(char)
            }
        }
        return digits
    }
    
    public static func formatPhoneNumberAfterRemovingNonDecimalCharacters(_ phoneNumber: String) -> String {
        return formatPhoneNumber(removeNonDecimalCharacters(phoneNumber))
    }
}
