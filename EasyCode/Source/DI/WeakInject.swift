//
//  WeakInject.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation

@propertyWrapper
public struct WeakInject<T: AnyObject> {

    private weak var value: T?

    public init(container: DependencyInjector = .shared) {
        value = try? container.resolve()
    }

    public var wrappedValue: T? { value }
}
