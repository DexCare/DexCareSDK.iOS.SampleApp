//
//  ConsoleLogger.swift
//  SampleApp
//
//  Created by Dominic Pepin on 2024-03-05.
//  Copyright © 2024 DexCare. All rights reserved.
//

import DexcareiOSSDK
import Foundation
import os.log

protocol LoggerType: DexcareSDKLogger {
    func log(_ message: String, level: DexcareSDKLogLevel, sender: OSLog)
}

public extension OSLog {
    private static let subsystem = "org.dexcare.dexcaresdk.sampleapp"

    static let `default` = OSLog(subsystem: subsystem, category: "Default")
    static let auth0 = OSLog(subsystem: subsystem, category: "Authentication")
    static let configuration = OSLog(subsystem: subsystem, category: "Configuration")
    static let dexcareSDK = OSLog(subsystem: subsystem, category: "DexCareSDK")
    static let providerBooking = OSLog(subsystem: subsystem, category: "Provider Booking")
    static let pushNotifications = OSLog(subsystem: subsystem, category: "Push Notifications")
    static let virtualVisit = OSLog(subsystem: subsystem, category: "Virtual Visit")
}

/// Logger that prints message to the console
class ConsoleLogger: LoggerType {
    func log(_ message: String, level: DexcareSDKLogLevel, sender: String) {
        log(message, level: level, sender: .dexcareSDK)
    }

    func log(_ message: String, level: DexcareSDKLogLevel, sender: OSLog = .default) {
        os_log("%{public}@", log: sender, type: level.osLogType, buildMessage(message: message, level: level))
    }

    // MARK: Private

    private func buildMessage(message: String, level: DexcareSDKLogLevel) -> String {
        "\(level.prefix) \(message)"
    }
}

// MARK: OSLog Extension

private extension DexcareSDKLogLevel {
    var prefix: String {
        switch self {
        case .verbose: return "💬 VERBOSE:"
        case .debug: return "⚙️ DEBUG:"
        case .info: return "ℹ️ INFO:"
        case .warning: return "⚠️ WARNING:"
        case .error: return "❌ ERROR:"
        }
    }

    var osLogType: OSLogType {
        switch self {
        case .verbose:
            return .debug
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .error
        case .error:
            return .error
        }
    }
}
