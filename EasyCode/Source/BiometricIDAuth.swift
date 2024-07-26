//
//  BiometricIDAuth.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 03.07.2024.
//

import LocalAuthentication

/// Class handling biometric authentication using LocalAuthentication framework.
public class BiometricIDAuth {

    /// Possible results of biometric authentication.
    public enum Result {
        case authenticated
        case fallbackAction
        case cancelled
        case disabledInSystemsAppSettings
        case failed
    }

    /// Enum representing the type of biometric authentication available on the device.
    public enum BiometryType {
        case none
        case touchID
        case faceID
        case unknown

        /// Provides a user-friendly title for each biometric type.
        public var title: String {
            switch self {
            case .none: return ""
            case .faceID: return "Face ID"
            case .touchID: return "Touch ID"
            case .unknown: return ""
            }
        }
    }

    private var context = LAContext()

    /// Initializes the `BiometricIDAuth` instance and evaluates the biometric policy.
    public init() { evaluatePolicy() }

    private func evaluatePolicy() { canEvaluatePolicy(for: context) }

    @discardableResult
    private func canEvaluatePolicy(for context: LAContext) -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    /// Determines the type of biometric authentication supported by the device.
    ///
    /// - Returns: The type of biometric authentication supported (`BiometryType`).
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

    /// Authenticates the user using biometric authentication.
    ///
    /// - Parameters:
    ///   - reason: The reason displayed to the user for authentication.
    ///   - fallbackTitle: The title for the fallback button (default is empty, which uses system default).
    ///   - cancelTitle: The title for the cancel button (default is empty, which uses system default).
    ///   - completion: A closure called with the authentication result (`Result`).
    ///
    /// # Example:
    ///
    /// ```swift
    /// let biometricAuth = BiometricIDAuth()
    /// biometricAuth.authenticateUser(reason: "Unlock access", completion: { result in
    ///     switch result {
    ///     case .authenticated:
    ///         print("User authenticated successfully.")
    ///         // Proceed to unlock sensitive data or perform secure action
    ///     case .fallbackAction:
    ///         print("User chose fallback action.")
    ///         // Handle fallback action (e.g., password authentication)
    ///     case .cancelled:
    ///         print("Authentication cancelled by user.")
    ///         // Handle cancellation
    ///     case .disabledInSystemsAppSettings:
    ///         print("Biometric authentication is disabled in system settings.")
    ///         // Inform user or prompt to enable biometrics
    ///     case .failed:
    ///         print("Authentication failed.")
    ///         // Handle authentication failure
    ///     }
    /// })
    /// ```
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
