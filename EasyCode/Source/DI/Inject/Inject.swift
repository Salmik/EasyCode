//
//  Inject.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation

@propertyWrapper
public struct Inject<T> {

    public var wrappedValue: T

    public init(container: DependencyInjector = DependencyInjector.shared) {
        do {
            self.wrappedValue = try container.resolve()
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }
}
