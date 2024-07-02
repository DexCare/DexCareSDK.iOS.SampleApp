//
//  AppDelegate.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-04-05.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    // MARK: UIApplicationDelegate

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Current.dexcareSDK.virtualService.updatePushNotificationDeviceToken(token: deviceToken)
        logDeviceToken(deviceToken)
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Current.logger.log("Failed to register for push notifications: \(error.localizedDescription)", level: .error, sender: .pushNotifications)
    }

    // MARK: Private

    private func logDeviceToken(_ deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Current.logger.log("Device Token: \(deviceTokenString)", level: .debug, sender: .pushNotifications)
    }
}
