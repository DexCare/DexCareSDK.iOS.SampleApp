//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import DexcareSDK
import Lock
import PromiseKit
import Auth0

class Configuration: Decodable {
    var auth0ClientId: String
    var auth0Domain: String
    var dexcareDomain: String
    var dexcareFhirOrchUrl: String
    var dexcareFhirOrchApiKey: String
    var dexcareVirtualVisitUrl: String
    var dexcarePcpUrl: String
    var userAgent: String
    var tenantName: String
    var pushNotificationAppId: String
    var pushNotificationPlatform: String
    var brand: String
    var ehrSystemName: String
    
    var loginEmail: String?
}

extension Configuration {
    enum Auth0Keys {
        static let appMetaData = "app_metadata"
        static let email = "email"
        static let scope = "openid offline_access"
    }
    
    var dexcareConfiguration: DexcareConfiguration {
        let virtualVisitConfig = VirtualVisitConfiguration(
            pushNotificationAppId: pushNotificationAppId,
            pushNotificationPlatform: pushNotificationPlatform,
            virtualVisitUrl: URL(string: dexcareVirtualVisitUrl)!
        )
        let environment = Environment(
            fhirOrchUrl: URL(string: dexcareFhirOrchUrl)!,
            virtualVisitConfiguration: virtualVisitConfig,
            dexcareAPIKey: dexcareFhirOrchApiKey,
            pcpURL: URL(string: dexcarePcpUrl)!
        )
        return DexcareConfiguration(
            environment: environment,
            userAgent: userAgent,
            domain: dexcareDomain,
            tenantName: tenantName,
            customStrings: nil,
            logger: ConsoleLogger()
        )
    }
    
    func showUniversalLogin(authToken: @escaping (String?) -> Void) {
        Auth0
            .webAuth(clientId: auth0ClientId, domain: auth0Domain)
            .scope("openid offline_access")
            .audience("https://\(auth0Domain)/api/v2/")
            .start { result in
                switch result {
                    case .failure(let error):
                        // Handle the error
                        print("Error: \(error)")
                    case .success(let credentials):
                        // Do something with credentials e.g.: save them.
                        // Auth0 will automatically dismiss the login page
                        print("Credentials: \(credentials.accessToken)")
                        // We've gotten a token from auth0
                        authToken(credentials.accessToken)
                        
                        self.loadUserInfo(accessToken: credentials.accessToken)
                }
        }
    }
    
    func showLogin(onViewController: UIViewController, authToken: @escaping (String?) -> Void) {
        Lock.classic(clientId: auth0ClientId, domain: auth0Domain)
            .withStyle {
                $0.hideTitle = false
                $0.title = "ACME"
                $0.headerColor = nil
                $0.backgroundColor  = .white
                $0.primaryColor = UIColor.init(named: "AccentColor") ?? .systemPurple
        }
        .withOptions {
            $0.oidcConformant = true
            $0.scope = "openid offline_access"
            $0.audience = "https://\(auth0Domain)/api/v2/"
        }
        .onAuth { credentials in
            // We've gotten a token from auth0
            authToken(credentials.accessToken)
           
            self.loadUserInfo(accessToken: credentials.accessToken)
        }
        .onError { error  in
            // Auth0 isn't set up properly most likley.
            print(String(describing: error))
            
        }
        .present(from: onViewController)
    }
    
    func loadUserInfo(accessToken: String?) {
        guard let accessToken = accessToken else { return }
        
        firstly {
            self.getUserProfile(accessToken: accessToken)
        }
        .then { profile in
            when(fulfilled: self.getMetadata(sub: profile.sub, accessToken: accessToken), Promise<String>.value(profile.sub))
        }.done { (metadata, userId) in
            self.loginEmail = userId
        }.catch { error in
            print("Error loading user info - \(error)")
        }
    }
    
 
    private func getUserProfile(accessToken: String) -> Promise<Auth0.UserInfo> {
        return Promise { seal in
            
             Auth0.authentication(clientId: auth0ClientId, domain: auth0Domain)
                .userInfo(withAccessToken: accessToken)
                .start { result in
                    switch(result) {
                        case .success(let userInfo):
                            seal.fulfill(userInfo)
                        case .failure(let error):
                            seal.reject(error)
                    }
            }
        }
    }
    
    private func getMetadata(sub: String, accessToken: String) -> Promise<([String:Any])> {
        let fields = [Auth0Keys.appMetaData, Auth0Keys.email]
        
        return Promise { seal in
            Auth0
                .users(token: accessToken, domain: auth0Domain)
                .get(sub, fields: fields, include: true)
                .start { result in
                    switch result {
                        case .success(let user):
                            seal.fulfill(user)
                        case .failure(let error):
                            seal.reject(error)
                    }
            }
        }
    }

}

extension Configuration {
    static func loadDefault() -> Configuration {
        return Configuration.load(tenantName: "acme")
    }
    
    static func load(tenantName: String) -> Configuration {
        let decoder = PropertyListDecoder()
        
        guard let plistURL = Bundle.main.url(forResource: tenantName, withExtension: "plist") else {
            fatalError("Could not find plist with name: \(tenantName)")
        }
        
        guard
            let data = try? Data.init(contentsOf: plistURL) else {
                fatalError("Error finding plist with name: \(tenantName)")
        }
        
        do {
            let config = try decoder.decode(Configuration.self, from: data)
            return config
        } catch {
            fatalError("Error creating Configuration object from from plist with name: \(tenantName) - \(error)")
        }
        
    }
}
