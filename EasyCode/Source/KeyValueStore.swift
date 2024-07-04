//
//  KeyValueStore.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public protocol KeyValueStoreKey {
    var rawValue: String { get }
}

public class KeyValueStore {

    enum DefaultKey: String, KeyValueStoreKey {
        case languageCode
        case theme
        case fcmToken
    }

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func getValue<T>(for key: KeyValueStoreKey) -> T? {
        userDefaults.value(forKey: key.rawValue) as? T
    }

    public func set<T>(value: T, for key: KeyValueStoreKey) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    public func removeValue(for key: KeyValueStoreKey) {
        userDefaults.removeObject(forKey: key.rawValue)
    }

    public func getValue<T: Codable>(for key: KeyValueStoreKey) -> T? {
        guard let data = userDefaults.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    public func set<T: Codable>(value: T, for key: KeyValueStoreKey) {
        if let encoded = try? JSONEncoder().encode(value) {
            userDefaults.set(encoded, forKey: key.rawValue)
        }
    }

    public func sync() {
        userDefaults.synchronize()
    }
}
