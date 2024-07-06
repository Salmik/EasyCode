//
//  EncryptionError.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

/// Enum defining various encryption-related errors.
public enum EncryptionError: Error, CustomDebugStringConvertible {

    /// Error indicating decryption failure.
    case decryptionFailed

    /// Error indicating an attempt to create an item that already exists.
    case alreadyExists

    /// Error indicating a password mismatch or retrieval error.
    case passwordMismatch

    /// Error indicating unexpected data retrieval failure.
    case unexpectedData

    /// Error indicating a Keychain operation failure with a specific status code.
    case keychainError(status: OSStatus)

    /// A textual representation of the error for debugging purposes.
    public var debugDescription: String {
        switch self {
        case .decryptionFailed:
            return "Error during password decryption."
        case .alreadyExists:
            return "Password already exists."
        case .passwordMismatch:
            return "Error retrieving the password."
        case .unexpectedData:
            return "Error retrieving data."
        case .keychainError(let status):
            return "Keychain operation error with status code: \(status)."
        }
    }
}
