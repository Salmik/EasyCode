//
//  KeychainWrapper.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation

@propertyWrapper
public struct KeychainWrapper {

    let key: KeychainKeyProtocol
    private let keychainService = KeychainService()

    public init(_ key: KeychainKeyProtocol) {
        self.key = key
    }

    public var wrappedValue: String? {
        get {
            do {
                let data = try keychainService.load(key: key)
                return String(data: data, encoding: .utf8)
            } catch {
                print("Keychain get error: \(error)")
                return nil
            }
        }
        set {
            if let newValue, let data = newValue.data(using: .utf8) {
                do {
                    try keychainService.save(key: key, data: data)
                } catch {
                    print("Keychain save error: \(error)")
                }
            } else {
                do {
                    try keychainService.delete(key: key)
                } catch {
                    print("Keychain delete error: \(error)")
                }
            }
        }
    }
}
