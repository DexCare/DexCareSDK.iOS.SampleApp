//  Copyright © 2020 DexCare. All rights reserved.

import Foundation

/// Validates 2-character subdivision codes for states, districts, and outlying areas for the United States per ISO 3166-2.
/// - seealso: https://www.iso.org/obp/ui/#iso:code:3166:US
/// - example: The code "WA" is valid and maps to the full ISO code "US-WA"
class UnitedStatesISO3166SubdivisionsValidator {
    
    private enum Constants {
        static let codeLength = 2
    }
    
    /// Known United States state codes
    static let stateCodes: [String] = [
        "AL",
        "AK",
        "AZ",
        "AR",
        "CA",
        "CO",
        "CT",
        "DE",
        "FL",
        "GA",
        "HI",
        "ID",
        "IL",
        "IN",
        "IA",
        "KS",
        "KY",
        "LA",
        "ME",
        "MD",
        "MA",
        "MI",
        "MN",
        "MS",
        "MO",
        "MT",
        "NE",
        "NV",
        "NH",
        "NJ",
        "NM",
        "NY",
        "NC",
        "ND",
        "OH",
        "OK",
        "OR",
        "PA",
        "RI",
        "SC",
        "SD",
        "TN",
        "TX",
        "UT",
        "VT",
        "VA",
        "WA",
        "WV",
        "WI",
        "WY"
    ]
    
    /// Known United States district codes
    static let districtCodes: [String] = [
        "DC"
    ]
    
    /// Known United States outlying area codes
    static let outlyingAreaCodes: [String] = [
        "AS",
        "GU",
        "MP",
        "PR",
        "UM",
        "VI"
    ]
    
    static func isValid(code: String) -> Bool {
        let uppercaseCode = code.uppercased()
        return stateCodes.contains(uppercaseCode)
            || districtCodes.contains(uppercaseCode)
            || outlyingAreaCodes.contains(uppercaseCode)
    }
}

class UnitedStatesISO3166SubdivisionsConverter {
    
    private static var statesDictionary = [
        "Alabama": "AL",
        "Alaska": "AK",
        "Arizona": "AZ",
        "Arkansas": "AR",
        "American Samoa": "AS",
        "California": "CA",
        "Colorado": "CO",
        "Connecticut": "CT",
        "District of Columbia": "DC",
        "Delaware": "DE",
        "Florida": "FL",
        "Georgia": "GA",
        "Guam": "GU",
        "Hawaii": "HI",
        "Idaho": "ID",
        "Illinois": "IL",
        "Indiana": "IN",
        "Iowa": "IA",
        "Kansas": "KS",
        "Kentucky": "KY",
        "Louisiana": "LA",
        "Maine": "ME",
        "Maryland": "MD",
        "Massachusetts": "MA",
        "Michigan": "MI",
        "Minnesota": "MN",
        "Mississippi": "MS",
        "Missouri": "MO",
        "Montana": "MT",
        "Nebraska": "NE",
        "Nevada": "NV",
        "New Hampshire": "NH",
        "New Jersey": "NJ",
        "New Mexico": "NM",
        "New York": "NY",
        "North Carolina": "NC",
        "North Dakota": "ND",
        "Northern Mariana Islands": "MP",
        "Ohio": "OH",
        "Oklahoma": "OK",
        "Oregon": "OR",
        "Pennsylvania": "PA",
        "Puerto Rico" : "PR",
        "Rhode Island": "RI",
        "South Carolina": "SC",
        "South Dakota": "SD",
        "Tennessee": "TN",
        "Texas": "TX",
        "Utah": "UT",
        "Vermont": "VT",
        "Virgin Islands": "VI",
        "Virginia": "VA",
        "Washington": "WA",
        "West Virginia": "WV",
        "Wisconsin": "WI",
        "Wyoming": "WY"
    ]
    
    static func stateCodeFor(_ stateText: String?) -> String? {
        guard let stateText = stateText else { return nil }
        
        let upperCase = stateText.uppercased()
        
        guard !statesDictionary.values.contains(upperCase) else { return upperCase }
        
        guard let stateCode = statesDictionary[stateText.capitalized] else { return nil }
        
        return stateCode
    }
}

