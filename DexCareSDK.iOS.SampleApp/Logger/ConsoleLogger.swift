//  Copyright © 2020 DexCare. All rights reserved.

import DexcareiOSSDK
import Foundation

class ConsoleLogger: DexcareSDKLogger {
    static var shared: ConsoleLogger = .init()

    func log(_ message: String, level: DexcareSDKLogLevel, sender: String) {
        let emoji: String
        switch level {
        case .verbose: emoji = "➡️"
        case .debug: emoji = "✳️"
        case .info: emoji = "✏️"
        case .warning: emoji = "⚠️"
        case .error: emoji = "❌"
        }
        NSLog("\(emoji) \(sender): \(message)")
    }
}
