//
//  Main.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-05.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

@main
struct Main: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
