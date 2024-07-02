//
//  EncryptionError.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public enum EncryptionError: Error, CustomDebugStringConvertible {

    case decryptionFailed
    case alreadyExists
    case passwordMismatch
    case unexpectedData
    case keychainError(status: OSStatus)

    public var debugDescription: String {
        switch self {
        case .decryptionFailed: return "Error during password decryption"
        case .alreadyExists: return "Password already exists"
        case .passwordMismatch: return "Error retrieving the password:"
        case .unexpectedData: return "Error retrieving data"
        default: return ""
        }
    }
}
