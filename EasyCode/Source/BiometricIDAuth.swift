//
//  BiometricIDAuth.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 03.07.2024.
//

import LocalAuthentication

public enum BiometryType {
    case none
    case touchID
    case faceID
    case unknown

    public var title: String {
        switch self {
        case .none: return ""
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .unknown: return ""
        }
    }
}

public class BiometricIDAuth {

    public enum Result {
        case authenticated
        case fallbackAction
        case cancelled
        case disabledInSystemsAppSettings
        case failed
    }

    private var context = LAContext()

    public init() { evaluatePolicy() }

    private func evaluatePolicy() { canEvaluatePolicy(for: context) }

    @discardableResult 
    private func canEvaluatePolicy(for context: LAContext) -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    public var biometryType: BiometryType {
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .touchID: return .touchID
            case .faceID: return .faceID
            case .none: return .none
            default: return .unknown
            }
        } else {
            return canEvaluatePolicy(for: context) ? .touchID : .none
        }
    }

    public func authenticateUser(
        reason: String = "",
        fallbackTitle: String = "",
        cancelTitle: String = "",
        completion: @escaping (_ result: Result) -> Void
    ) {
        context = LAContext()
        evaluatePolicy()

        let biometryTitle = biometryType.title
        let localizedReason = reason.isEmpty ? "Authentication with " + biometryTitle : reason

        context.localizedFallbackTitle = fallbackTitle
        context.localizedCancelTitle = cancelTitle
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: localizedReason
        ) { success, error in
            DispatchQueue.main.async {
                if success { return completion(.authenticated) }
                guard let error = error as? LAError else { return completion(.failed) }
                self.handle(error: error, completion: completion)
            }
        }
    }

    private func handle(error: LAError, completion: @escaping (_ result: Result) -> Void) {
        switch error.code {
        case .userFallback: completion(.fallbackAction)
        case .systemCancel, .userCancel, .appCancel: completion(.cancelled)
        case .biometryNotAvailable: completion(.disabledInSystemsAppSettings)
        default: completion(.failed)
        }
    }
}
