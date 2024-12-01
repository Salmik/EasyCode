//
//  WeakProvider.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation

@propertyWrapper
public struct WeakProvider<T: AnyObject> {

    public var wrappedValue: T

    public init(wrappedValue: T, container: DependencyInjector = DependencyInjector.shared) {
        self.wrappedValue = wrappedValue
        container.registerWeak(dependency: wrappedValue)
    }
}
