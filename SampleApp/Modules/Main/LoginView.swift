//
//  LoginView.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-05.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import Lock
import SwiftUI

/// Login View (where user will enter their username and password)
struct LoginView: View {
    // MARK: Properties

    @SwiftUI.Environment(\.presentationMode) private var presentationMode

    // MARK: Body

    var body: some View {
        NavigationStack {
            InternalLoginView()
                .navigationTitle("LoginView.Title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Common.Close")
                        }
                    }
                }
        }
    }
}

private struct InternalLoginView: UIViewControllerRepresentable {
    // MARK: Properties

    private let appConfiguration: DexConfig
    private let authService: Auth0AuthServiceType
    private let logger: LoggerType

    // MARK: Lifecycle

    init(
        appConfiguration: DexConfig = Current.configurationService.selectedAppConfiguration,
        authService: Auth0AuthServiceType = Current.authenticationService,
        logger: LoggerType = Current.logger
    ) {
        self.appConfiguration = appConfiguration
        self.authService = authService
        self.logger = logger
    }

    // MARK: Auth0AuthServiceType

    func makeUIViewController(context _: Context) -> LockViewController {
        Lock
            .classic(
                clientId: authService.auth0ClientId,
                domain: authService.auth0Domain
            )
            .withStyle {
                $0.hideTitle = false
                $0.title = appConfiguration.configName
                $0.headerColor = nil
                $0.backgroundColor = UIColor(Color.dxBackgroundPrimary)
                $0.primaryColor = UIColor(Color.dxTextPrimary)
            }
            .withOptions {
                $0.oidcConformant = true
                $0.scope = authService.auth0Scope
                $0.audience = "https://\(authService.auth0Domain)/api/v2/"
            }
            .onAuth { credentials in
                authService.onLogInSuccess(with: credentials)
            }
            .onError { error in
                logger.log("Error: Failed to configure Auth0. Error: \(error)", level: .error, sender: .auth0)
            }
            .controller
    }

    public func updateUIViewController(_: LockViewController, context _: Context) {}
}

#Preview {
    LoginView()
}
