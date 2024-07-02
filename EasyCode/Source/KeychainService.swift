//
//  KeychainService.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import Security

public class KeychainService {

    public enum KeychainKey: String {

        case mySecretKey = "MySecretKey"
        case userToken = "UserToken"
        case sessionData = "SessionData"
    }

    @discardableResult
    static func save(key: KeychainKey, data: Data) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ] as [String: Any]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == noErr
    }

    static func load(key: KeychainKey) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: kCFBooleanTrue ?? "",
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]

        var dataTypeRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard status == noErr else { return nil }
        return dataTypeRef as? Data
    }

    @discardableResult
    static func update(key: KeychainKey, data: Data) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ] as [String: Any]

        let attributesToUpdate = [kSecValueData as String: data] as [String: Any]

        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        return status == noErr
    }

    @discardableResult
    static func delete(key: KeychainKey) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ] as [String: Any]

        let status = SecItemDelete(query as CFDictionary)
        return status == noErr
    }
}
