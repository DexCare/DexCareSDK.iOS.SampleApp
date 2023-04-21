import Auth0
import Foundation
import JWTDecode
import KeychainAccess
import Lock

enum AccountServiceError: Error {
    case userCancelled
    case tokenExpected
    case couldNotGetEmailFromMetadata
    case signOutFailed
    case refreshTokenError(Error)
    case missingLoginEmail
    case missingInformation(String)
}

class Auth0AccountManager {
    enum Auth0AccountManagerError: Error {
        case expectedTokenNotFoundInKeychain
        case expectedCredentialsToContainRefreshToken
    }

    enum Auth0Keys {
        static let appMetaData = "app_metadata"
        static let email = "email"
        static let scope = "openid offline_access"
    }

    let auth0ClientId: String
    let auth0Domain: String

    var credentials: Credentials?
    let logger = ConsoleLogger()

    var canLogInWithBiometrics: Bool {
        return AppServices.shared.biometricsService.hasBiometrics && hasAccessToken
    }

    var hasAccessToken: Bool {
        return AppServices.shared.loginStoreService.hasStoredCredentials
    }

    private var authentication: Authentication

    init(auth0ClientId: String, auth0Domain: String) {
        self.auth0ClientId = auth0ClientId
        self.auth0Domain = auth0Domain

        // used to renew tokens
        authentication = Auth0.authentication(clientId: auth0ClientId, domain: auth0Domain)
    }

    func showUniversalLogin() async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            Auth0
                .webAuth(clientId: auth0ClientId, domain: auth0Domain)
                .scope("openid offline_access")
                .audience("https://\(auth0Domain)/api/v2/")
                .start { result in
                    switch result {
                    case let .failure(error):
                        // Handle the error
                        print("Error: \(error)")
                        continuation.resume(throwing: error)
                    case let .success(credentials):
                        // Do something with credentials e.g.: save them.
                        // Auth0 will automatically dismiss the login page
                        // We've gotten a token from auth0
                        
                        self.credentials = credentials
                        self.updateCredentialsInLoginStore(credentials)
                        Task {
                            try await self.loadUserInfo(accessToken: credentials.accessToken)
                        }
                        continuation.resume(returning: credentials.accessToken)
                    }
                }
        }
    }

    func showLogin(onViewController: UIViewController, authToken: @escaping (String?) -> Void) {
        Lock.classic(clientId: auth0ClientId, domain: auth0Domain)
            .withStyle {
                $0.hideTitle = false
                $0.title = "ACME"
                $0.headerColor = nil
                $0.backgroundColor = .white
                $0.primaryColor = UIColor(named: "AccentColor") ?? .systemPurple
            }
            .withOptions {
                $0.oidcConformant = true
                $0.scope = "openid offline_access"
                $0.audience = "https://\(auth0Domain)/api/v2/"
            }
            .onAuth { credentials in
                // save the credentials object as we'll need the refresh token later to try and renew
                self.credentials = credentials
                self.updateCredentialsInLoginStore(credentials)

                // sends back the accessToken in the closure
                authToken(credentials.accessToken)

                Task {
                    // loads user info from Auth0 to get various information.
                    try await self.loadUserInfo(accessToken: credentials.accessToken)
                }
            }
            .onError { error in
                // Auth0 isn't set up properly most likely.
                print(String(describing: error))
            }
            .present(from: onViewController)
    }

    func renewToken() async throws -> String? {
        guard let refreshToken = credentials?.refreshToken else {
            throw AccountServiceError.tokenExpected
        }
        return try await renewToken(refreshToken: refreshToken)
    }

    private func renewToken(refreshToken: String) async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            authentication.renew(withRefreshToken: refreshToken, scope: Auth0Keys.scope)
                .start { [weak self] credentials in
                    guard let strongSelf = self else { return }
                    switch credentials {
                    case let .success(credentials):
                        let newCredentials = Credentials(accessToken: credentials.accessToken,
                                                         tokenType: credentials.tokenType,
                                                         idToken: credentials.idToken,
                                                         refreshToken: refreshToken,
                                                         expiresIn: credentials.expiresIn,
                                                         scope: credentials.scope)
                        
                        strongSelf.credentials = newCredentials
                        
                        strongSelf.updateCredentialsInLoginStore(credentials)
                        continuation.resume(returning: newCredentials.accessToken)
                        
                    case let .failure(error):
                        continuation.resume(throwing: AccountServiceError.refreshTokenError(error))
                    }
                }
        }
    }

    func updateCredentialsInLoginStore(_ credentials: Credentials) {
        removeAnyExistingCredentialsInLoginStore()
        storeCredentialsInLoginStore(credentials)
    }

    /// Makes a best-effort attempt to remove existing credentials if present in login store.
    private func removeAnyExistingCredentialsInLoginStore() {
        if AppServices.shared.loginStoreService.hasStoredCredentials {
            do {
                try AppServices.shared.loginStoreService.removeCredentials()
            } catch {
                logger.log("Failed to remove existing credentials when storing updated credentials: \(String(describing: error))", level: .warning, sender: #file)
            }
        }
    }

    /// Makes a best-effort attempt to store credentials in login store.
    private func storeCredentialsInLoginStore(_ credentials: Credentials) {
        do {
            try AppServices.shared.loginStoreService.storeCredentials(credentials)
        } catch {
            logger.log("Failed to store credentials in login store: \(String(describing: error)).", level: .warning, sender: #file)
        }
    }

    func signInWithAuthToken() async throws -> String? {
        return try await fetchStoredOrRenewedAccessToken()
    }

    func fetchStoredOrRenewedAccessToken() async throws -> String? {
        do {
            guard let credentials = try getCredentialsFromLoginStore() else {
                throw Auth0AccountManagerError.expectedTokenNotFoundInKeychain
            }
            if hasExpired(credentials) {
                // credentials we have saved, lets try to refresh it
                guard let refreshToken = credentials.refreshToken else {
                    do {
                        try AppServices.shared.loginStoreService.removeCredentials()
                    } catch {
                        logger.log("Failed to remove expired credentials without a refresh token from login store. Error: \(String(describing: error))", level: .error, sender: #file)
                    }
                    throw Auth0AccountManagerError.expectedCredentialsToContainRefreshToken
                }
                return try await renewToken(refreshToken: refreshToken)
            } else {
                self.credentials = credentials
                return credentials.accessToken
            }
        } catch {
            if let statusError = error as? Status, statusError == Status.userCanceled {
                // Biometrics prompt cancelled by user, token not available from Keychain
                throw AccountServiceError.userCancelled
            }
            logger.log("Error fetching auth token from Keychain: \(String(describing: error))", level: .error, sender: #file)
            throw error
        }
    }

    func getCredentialsFromLoginStore() throws -> Credentials? {
        return try AppServices.shared.loginStoreService.fetchCredentials()
    }

    func loadUserInfo(accessToken: String?) async throws {
        guard let accessToken = accessToken else { return }

        let profile = try await getUserProfile(accessToken: accessToken)
        let _ = try await getMetadata(sub: profile.sub, accessToken: accessToken)

        // Use what you need here. Any information stored in Auth0 Metadata can be grabbed
        print("UserId: \(profile.sub)")
    }

    private func hasExpired(_ credentials: Credentials) -> Bool {
        if let expiresIn = credentials.expiresIn {
            if expiresIn < Date() { return true }
        }

        if let token = credentials.idToken, let jwt = try? decode(jwt: token) {
            return jwt.expired
        }

        return false
    }

    private func getUserProfile(accessToken: String) async throws -> Auth0.UserInfo {
        try await withCheckedThrowingContinuation { continuation in
            Auth0.authentication(clientId: auth0ClientId, domain: auth0Domain)
                .userInfo(withAccessToken: accessToken)
                .start { result in
                    switch result {
                    case let .success(userInfo):
                        continuation.resume(returning: userInfo)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    private func getMetadata(sub: String, accessToken: String) async throws -> [String: Any] {
        try await withCheckedThrowingContinuation { continuation in
            let fields = [Auth0Keys.appMetaData, Auth0Keys.email]
            Auth0
                .users(token: accessToken, domain: auth0Domain)
                .get(sub, fields: fields, include: true)
                .start { result in
                    switch result {
                    case let .success(user):
                        continuation.resume(returning: user)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
