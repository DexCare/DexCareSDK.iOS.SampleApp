//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import DexcareiOSSDK

class ConsoleLogger: DexcareSDKLogger {
    
    static var shared: ConsoleLogger = ConsoleLogger()
    
    func log(_ message: String, level: DexcareSDKLogLevel, sender: String) {
        let emoji: String
        switch level {
            case .verbose: emoji = "➡️"
            case .debug: emoji = "✳️"
            case .info: emoji = "✏️"
            case .warning: emoji = "⚠️"
            case .error: emoji = "❌"
            @unknown default:
                emoji = "❌"
        }
        NSLog("\(emoji) \(sender): \(message)")
    }
}
