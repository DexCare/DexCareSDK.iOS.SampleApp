//
//  Auth0AuthService.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-05.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Auth0
import Combine
import DexcareiOSSDK
import Foundation

public enum AuthState {
    case unknown
    case unauthenticated
    case authenticated
}

protocol Auth0AuthServiceType {
    var authStatePublisher: AnyPublisher<AuthState, Never> { get }
    var authState: AuthState { get }
    var auth0ClientId: String { get }
    var auth0Domain: String { get }
    var auth0Scope: String { get }
    func onLogInSuccess(with: Credentials)
    func logOut()
}

/// Service that manages the authentication state
/// Notes:
///  - This service uses Auth0 to authenticate
///  - The actual authentication will be done via the LoginView using Lock
class Auth0AuthService: Auth0AuthServiceType {
    private let authentication: Authentication
    private let credentialsManager: CredentialsManager
    private let dexcareSDK: DexcareSDK
    private let logger: LoggerType
    private let userDefaultsService: UserDefaultsServiceType

    let auth0ClientId: String
    let auth0Domain: String
    var auth0Scope: String {
        "openid offline_access"
    }

    @Published private(set) var authState: AuthState {
        didSet {
            logger.log("Auth State = \(authState)", level: .debug, sender: .auth0)
        }
    }

    var authStatePublisher: AnyPublisher<AuthState, Never> {
        $authState.eraseToAnyPublisher()
    }

    // MARK: Lifecycle

    init(
        auth0ClientId: String,
        auth0Domain: String,
        dexcareSDK: DexcareSDK,
        logger: LoggerType,
        userDefaultsService: UserDefaultsServiceType
    ) {
        self.auth0ClientId = auth0ClientId
        self.auth0Domain = auth0Domain
        authentication = Auth0.authentication(clientId: auth0ClientId, domain: auth0Domain)
        credentialsManager = CredentialsManager(authentication: authentication, storeKey: "SampleAppCredentials")
        self.dexcareSDK = dexcareSDK
        self.logger = logger
        authState = .unknown
        self.userDefaultsService = userDefaultsService

        try? renewToken()
    }

    // MARK: Internal Methods

    func onLogInSuccess(with credentials: Credentials) {
        if let accessToken = credentials.accessToken, credentialsManager.store(credentials: credentials), credentialsManager.hasValid() {
            dexcareSDK.signIn(accessToken: accessToken)
            authState = .authenticated
        } else {
            authState = .unauthenticated
            logger.log("Failed to store credentials", level: .error, sender: .auth0)
        }
    }

    func logOut() {
        dexcareSDK.signOut()
        userDefaultsService.clearAll()
        authState = .unauthenticated
        if !credentialsManager.clear() {
            logger.log("Failed to clear credentials", level: .error, sender: .auth0)
        }
    }

    // MARK: Private

    private func renewToken() throws {
        guard credentialsManager.hasValid() else {
            authState = .unauthenticated
            return
        }

        Task {
            credentialsManager.credentials { error, credentials in
                guard let refreshToken = credentials?.refreshToken, error == nil else {
                    self.authState = .unauthenticated
                    return
                }

                self.authentication
                    .renew(withRefreshToken: refreshToken, scope: self.auth0Scope)
                    .start { [weak self] credentials in
                        guard let self else { return }
                        switch credentials {
                        case let .success(credentials):
                            let newCredentials = Credentials(
                                accessToken: credentials.accessToken,
                                tokenType: credentials.tokenType,
                                idToken: credentials.idToken,
                                refreshToken: refreshToken, // Renew does not return us our refresh token
                                expiresIn: credentials.expiresIn,
                                scope: credentials.scope
                            )

                            if !credentialsManager.store(credentials: newCredentials) {
                                logger.log("Failed to store credentials", level: .error, sender: .auth0)
                            }

                            if let accessToken = credentials.accessToken {
                                dexcareSDK.signIn(accessToken: accessToken)
                                authState = .authenticated
                                logger.log("Renewed auth token", level: .debug, sender: .auth0)
                            } else {
                                logger.log("Failed to renew access token.", level: .warning, sender: .auth0)
                                authState = .unauthenticated
                            }

                        case let .failure(error):
                            logger.log("Failed to renew auth token. Error: \(error)", level: .warning, sender: .auth0)
                            authState = .unauthenticated
                        }
                    }
            }
        }
    }
}
