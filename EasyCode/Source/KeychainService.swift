//
//  KeychainService.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import Security

/// A protocol that defines the required property for a key used in the Keychain.
public protocol KeychainKeyProtocol {
    var rawValue: String { get }
}

/// A class that provides methods to interact with the Keychain for saving, loading, updating, and deleting data.
public class KeychainService {

    /// An enumeration representing possible errors that can occur when interacting with the Keychain.
    public enum KeychainError: Error {
        case itemNotFound
        case unexpectedData
        case unhandledError(status: OSStatus)
    }

    private let secClass = kSecClass as String
    private let secAttrAccount = kSecAttrAccount as String
    private let secValueData = kSecValueData as String
    private let secReturnData = kSecReturnData as String
    private let secMatchLimit = kSecMatchLimit as String
    private let secClassGenericPassword = kSecClassGenericPassword as String
    private let secMatchLimitOne = kSecMatchLimitOne as String

    public init() {}

    /// Saves data to the Keychain for the specified key.
    ///
    /// - Parameters:
    ///   - key: The key to associate with the data.
    ///   - data: The data to save.
    /// - Returns: A Boolean value indicating whether the save operation was successful.
    /// - Throws: A KeychainError if the save operation fails.
    ///
    /// # Example:
    /// ``` swift
    /// try KeychainService().save(key: myKey, data: myData)
    /// ```
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

    /// Loads data from the Keychain for the specified key.
    ///
    /// - Parameter key: The key associated with the data to load.
    /// - Returns: The data associated with the specified key.
    /// - Throws: A KeychainError if the load operation fails.
    ///
    /// # Example:
    /// ``` swift
    /// let data = try KeychainService().load(key: myKey)
    /// ```
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

    /// Updates data in the Keychain for the specified key.
    ///
    /// - Parameters:
    ///   - key: The key associated with the data to update.
    ///   - data: The new data to save.
    /// - Returns: A Boolean value indicating whether the update operation was successful.
    /// - Throws: A KeychainError if the update operation fails.
    ///
    /// # Example:
    /// ``` swift
    /// try KeychainService().update(key: myKey, data: myUpdatedData)
    /// ```
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

    /// Deletes data from the Keychain for the specified key.
    ///
    /// - Parameter key: The key associated with the data to delete.
    /// - Returns: A Boolean value indicating whether the delete operation was successful.
    /// - Throws: A KeychainError if the delete operation fails.
    ///
    /// # Example:
    /// ``` swift
    /// try KeychainService().delete(key: myKey)
    /// ```
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
