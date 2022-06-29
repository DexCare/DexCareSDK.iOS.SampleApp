
import Foundation
import LocalAuthentication
import PromiseKit

// sourcery: AutoMockable
public protocol BiometricsServiceType {
    // sourcery: DefaultMockValue = true
    var hasBiometrics: Bool { get }
    // sourcery: DefaultMockValue = .none
    var type: BiometryType { get }
}

// Because iOS 11.0-11.2 does not have .none case, and to
// better encapsulate LocalAuthetication library, we wrap LABiometryType with our own type.
// This will keep rest of the app from needing "if #available(iOS 11.2, *)" code.
public enum BiometryType {
    case none
    case touchID
    case faceID
}

public class BiometricsService: BiometricsServiceType {
    let context = LAContext()

    public var hasBiometrics: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    public var type: BiometryType {
        // context.biometryType defaults to .none until after first call to canEvaluatePolicy
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return .none
        }
        // convert LABiometryType to BiometryType
        switch context.biometryType {
        case .touchID: return .touchID
        case .faceID: return .faceID
        case .none: return .none
        @unknown default: return .none
        }
    }
}

extension BiometryType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none: return ""
        case .touchID: return "TouchID"
        case .faceID: return "FaceID"
        }
    }
}
