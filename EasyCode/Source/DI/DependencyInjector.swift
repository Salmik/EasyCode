//
//  DependencyInjector.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation

private protocol OptionalType {
    static var wrappedType: Any.Type { get }
}

public class DependencyInjector {

    private var dependencies: [String: Any] = [:]
    private let queue = DispatchQueue(label: "DependencyContainer.Queue", attributes: .concurrent)

    public init() {}

    public func resolve<T>() throws -> T {
        let baseType: Any.Type
        if let optionalMeta = T.self as? OptionalType.Type {
            baseType = optionalMeta.wrappedType
        } else {
            baseType = T.self
        }

        let key = String(describing: baseType)

        return try queue.sync {
            guard let dependency = dependencies[key], let typed = dependency as? T else {
                throw DependencyError.providerNotFound(type: T.self)
            }
            return typed
        }
    }

    public func register<T>(dependency: T) {
        let key = String(describing: T.self)
        queue.async(flags: .barrier) {
            self.dependencies[key] = dependency
        }
    }

    public func unregister<T>(_ type: T.Type) {
        let baseType: Any.Type
        if let optionalMeta = type as? OptionalType.Type {
            baseType = optionalMeta.wrappedType
        } else {
            baseType = type
        }

        let key = String(describing: baseType)

        queue.async(flags: .barrier) {
            self.dependencies.removeValue(forKey: key)
        }
    }

    public func unregisterAll() {
        queue.async(flags: .barrier) {
            self.dependencies.removeAll()
        }
    }
}

extension DependencyInjector {
    public static let shared = DependencyInjector()
}

extension Optional: OptionalType {
    static var wrappedType: Any.Type { Wrapped.self }
}
