//
//  UserDefault.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation

@propertyWrapper
public struct UserDefault<V> {

    public let key: String

    public init(_ key: String) {
        self.key = key
    }

    public var wrappedValue: V? {
        get { UserDefaults.standard.object(forKey: key) as? V }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}
