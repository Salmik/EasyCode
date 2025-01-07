//
//  UnownedInject.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 07.01.2025.
//

import Foundation

@propertyWrapper
public struct UnownedInject<T: AnyObject> {

    private unowned var value: T

    public init(container: DependencyInjector = .shared) {
        do {
            value = try container.resolve()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    public var wrappedValue: T { value }
}
