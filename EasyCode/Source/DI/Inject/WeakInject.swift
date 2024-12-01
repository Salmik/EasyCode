//
//  WeakInject.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation

@propertyWrapper
public struct WeakInject<T: AnyObject> {

    private var value: T?

    public init(container: DependencyInjector = DependencyInjector.shared) {
        if let resolvedDependency: T = try? container.weakResolve() {
            self.value = resolvedDependency
        } else {
            self.value = nil
        }
    }

    public var wrappedValue: T? { value }
}
