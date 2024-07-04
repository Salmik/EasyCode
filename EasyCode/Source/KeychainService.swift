//
//  KeychainService.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import Security

public protocol KeychainKeyProtocol {
    var rawValue: String { get }
}

public enum KeychainError: Error {
    case itemNotFound
    case unexpectedData
    case unhandledError(status: OSStatus)
}

public class KeychainService {

    private let secClass = kSecClass as String
    private let secAttrAccount = kSecAttrAccount as String
    private let secValueData = kSecValueData as String
    private let secReturnData = kSecReturnData as String
    private let secMatchLimit = kSecMatchLimit as String
    private let secClassGenericPassword = kSecClassGenericPassword as String
    private let secMatchLimitOne = kSecMatchLimitOne as String

    public init() {}

    @discardableResult
    public func save(key: KeychainKeyProtocol, data: Data) throws -> Bool {
        let query = [
            secClass: secClassGenericPassword,
            secAttrAccount: key.rawValue,
            secValueData: data
        ] as [String: Any]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        return true
    }

    public func load(key: KeychainKeyProtocol) throws -> Data {
        let query = [
            secClass: secClassGenericPassword,
            secAttrAccount: key.rawValue,
            secReturnData: kCFBooleanTrue ?? "",
            secMatchLimit: secMatchLimitOne
        ] as [String: Any]

        var dataTypeRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

        guard let data = dataTypeRef as? Data else {
            throw KeychainError.unexpectedData
        }

        return data
    }

    @discardableResult
    public func update(key: KeychainKeyProtocol, data: Data) throws -> Bool {
        let query = [secClass: secClassGenericPassword, secAttrAccount: key.rawValue] as [String: Any]
        let attributesToUpdate = [secValueData: data] as [String: Any]
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

        return true
    }

    @discardableResult
    public func delete(key: KeychainKeyProtocol) throws -> Bool {
        let query = [secClass: secClassGenericPassword, secAttrAccount: key.rawValue] as [String: Any]
        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

        return true
    }
}
