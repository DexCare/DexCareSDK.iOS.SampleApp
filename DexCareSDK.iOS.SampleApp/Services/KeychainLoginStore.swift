import Foundation
import KeychainAccess
import LocalAuthentication
import DexcareSDK
import class Auth0.Credentials

extension Keychain {
    private static let KeychainAccessServiceBundleID: String = {
        if NSClassFromString("XCTestCase") != nil {
            return "com.providence.TestTarget"
        }
        else {
            return Bundle.main.bundleIdentifier ?? ""
        }
    }()
    
    static func keychainForCurrentBundleID() -> Keychain {
        return Keychain(service: Keychain.KeychainAccessServiceBundleID)
    }
}


// Using a random string for key is for added security in case keychain is compromised
// This enum can't be embedded in KeychainStore because it's a generic type
enum KeychainKey: String {
    case authToken = "vN3FQR9IfwTSzmasdf22hkl59X"
}

// sourcery: AutoMockable
protocol SecureLoginStoreType {
    // sourcery: DefaultMockValue = false
    var hasStoredCredentials: Bool { get }
    
    func storeCredentials(_ credentials: Credentials) throws
    func fetchCredentials() throws -> Credentials?
    func removeCredentials() throws
}

typealias LoginCredentials = (username: String, password: String)

class KeychainLoginStore: SecureLoginStoreType {
    fileprivate let keychain = Keychain.keychainForCurrentBundleID()
    fileprivate var context = LAContext()
    
    private var biometricsService: BiometricsServiceType
    private let logger: DexcareSDKLogger
    
    init(biometricsService: BiometricsServiceType, logger: DexcareSDKLogger) {
        self.biometricsService = biometricsService
        self.logger = logger
    }
    
    var hasStoredCredentials: Bool {
        do {
            return try hasCredentialsInKeychain()
        }
        catch {
            return false
        }
    }
    
    // MARK: Credentials
    func storeCredentials(_ credentials: Credentials) throws {
        let tokenData = try dataFromCredentials(credentials)
        try storeTokenData(tokenData)
    }
    
    func fetchCredentials() throws -> Credentials? {
        guard let tokenData = try fetchTokenData() else {
            return nil
        }
        let credentials = credentialsFromData(tokenData)
        return credentials
    }
    
    func removeCredentials() throws {
        try removeTokenData()
    }
    
    private func dataFromCredentials(_ credentials: Credentials) throws -> Data {
        let data = NSKeyedArchiver.archivedData(withRootObject: credentials)
        return data
//        return try NSKeyedArchiver.archivedData(withRootObject: credentials, requiringSecureCoding: true)
    }
    
    private func credentialsFromData(_ data: Data) -> Credentials? {
       return NSKeyedUnarchiver.unarchiveObject(with: data) as? Credentials
    }
    
    // MARK: Auth Token
    
    private func storeTokenData(_ tokenData: Data) throws {
        if biometricsService.hasBiometrics {
            // Authentication policy `.touchIDAny` will stop iOS from using the device passcode as a fall back if biometrics check fails
            try keychain.accessibility(.afterFirstUnlockThisDeviceOnly, authenticationPolicy: .biometryAny).set(tokenData, key: KeychainKey.authToken.rawValue)
            
            // N.B. On iOS Simulator with enrolled Face ID, stored token isn't always retrievable from keychain
        }
        else {
            // saves the credentials in the keychain
            try keychain.accessibility(.afterFirstUnlockThisDeviceOnly).set(tokenData, key: KeychainKey.authToken.rawValue)
        }
    }
    
    private func fetchTokenData() throws -> Data? {
        // First check if token data is contained in keychain, without loading it.
        guard hasStoredCredentials else {
            return nil
        }
        
        // Then load the token data (which will prompt for biometrics).
        
        let promptText = String(format: "Sign in with %@", biometricsService.type.description)
        
        // N.B. This will throw if biometrics check fails or is cancelled by user (when biometrics enabled)
        let tokenData = try keychain.authenticationPrompt(promptText).getData(KeychainKey.authToken.rawValue)
        
        if tokenData == nil {
            // Unexpected - token data should be contained in keychain, and biometrics check (if enabled) passed
            logger.log("Failed to load token data from keychain that should exist.", level: .warning, sender: #file)
            
            // Try to remove the token data to get to a clean slate
            do {
                try removeTokenData()
            } catch {
                logger.log("Failed to remove token data from keychain after load failure. Removal error: \(String(describing: error))", level: .warning, sender: #file)
            }
        }
        return tokenData
    }
    
    private func hasCredentialsInKeychain() throws -> Bool {
        // N.B. checks for stored token without prompting biometrics
        return try keychain.contains(KeychainKey.authToken.rawValue, withoutAuthenticationUI: true)
    }
    
    private func removeTokenData() throws {
        try keychain.remove(KeychainKey.authToken.rawValue)
    }
    
    // MARK: - Secure Set
    
    private func set(value: String?, forKey key: KeychainKey) throws {
        if let value = value {
            try keychain.accessibility(.afterFirstUnlockThisDeviceOnly)
                .set(value, key: key.rawValue)
        }
        else {
            try keychain.remove(key.rawValue)
        }
    }
}
