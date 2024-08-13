//
//  UserDefaultsStore.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

/// A protocol that defines the required property for a key used in the UserDefaultsStore.
public protocol UserDefaultsStoreKey {
    var rawValue: String { get }
}

/// A class that provides methods to interact with the UserDefaults for saving, loading, updating, and deleting data.
public class UserDefaultsStore {

    /// Enumeration for default keys used in the KeyValueStore.
    enum DefaultKey: String, UserDefaultsStoreKey {
        case languageCode
        case theme
        case fcmToken
    }

    private let userDefaults: UserDefaults

    /// Initializes a new instance of the UserDefaultsStore class.
    ///
    /// - Parameter userDefaults: The UserDefaults instance to use. Defaults to `.standard`.
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Retrieves a value for the specified key.
    ///
    /// - Parameter key: The key associated with the value to retrieve.
    /// - Returns: The value associated with the specified key, or nil if the key does not exist or the value cannot be cast to the expected type.
    ///
    /// # Example:
    /// ``` swift
    /// let theme: String? = keyValueStore.getValue(for: DefaultKey.theme)
    /// ```
    public func getValue<T>(for key: UserDefaultsStoreKey) -> T? {
        return userDefaults.value(forKey: key.rawValue) as? T
    }

    /// Sets a value for the specified key.
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - key: The key to associate with the value.
    ///
    /// # Example:
    /// ``` swift
    /// keyValueStore.set(value: "dark", for: DefaultKey.theme)
    /// ```
    public func set<T>(value: T, for key: UserDefaultsStoreKey) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    /// Removes a value for the specified key.
    ///
    /// - Parameter key: The key associated with the value to remove.
    ///
    /// # Example:
    /// ``` swift
    /// keyValueStore.removeValue(for: DefaultKey.theme)
    /// ```
    public func removeValue(for key: UserDefaultsStoreKey) {
        userDefaults.removeObject(forKey: key.rawValue)
    }

    /// Retrieves a Codable value for the specified key.
    ///
    /// - Parameter key: The key associated with the value to retrieve.
    /// - Returns: The Codable value associated with the specified key, or nil if the key does not exist or the value cannot be decoded.
    ///
    /// # Example:
    /// ``` swift
    /// struct User: Codable {
    ///     let name: String
    ///     let age: Int
    /// }
    ///
    /// let user: User? = keyValueStore.getValue(for: DefaultKey.user)
    /// ```
    public func getValue<T: Codable>(for key: UserDefaultsStoreKey) -> T? {
        guard let data = userDefaults.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// Sets a Codable value for the specified key.
    ///
    /// - Parameters:
    ///   - value: The Codable value to set.
    ///   - key: The key to associate with the value.
    ///
    /// # Example:
    /// ``` swift
    /// struct User: Codable {
    ///     let name: String
    ///     let age: Int
    /// }
    ///
    /// let user = User(name: "John Doe", age: 30)
    /// keyValueStore.set(value: user, for: DefaultKey.user)
    /// ```
    public func set<T: Codable>(value: T, for key: UserDefaultsStoreKey) {
        if let encoded = try? JSONEncoder().encode(value) {
            userDefaults.set(encoded, forKey: key.rawValue)
        }
    }

    /// Synchronizes the UserDefaults database.
    public func sync() {
        userDefaults.synchronize()
    }
}
