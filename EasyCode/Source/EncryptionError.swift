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
        case .decryptionFailed: return "Ошибка при расшивровки пароля"
        case .alreadyExists: return "Пароль уже существует"
        case .passwordMismatch: return "Ошибка при получении пароля:"
        case .unexpectedData: return "Ошибка при получении данных"
        default: return ""
        }
    }
}
