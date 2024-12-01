//
//  DependencyInjector.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 19.11.2024.
//

import Foundation

public class DependencyInjector {

    private var strongDependencies: [String: Any] = [:]
    private var weakDependencies: [String: WeakBox] = [:]
    private let queue = DispatchQueue(label: "DependencyContainer.Queue", attributes: .concurrent)

    public func resolve<T>() throws -> T {
        let key = String(describing: T.self)
        return try queue.sync {
            if let dependency = strongDependencies[key] as? T {
                return dependency
            } else {
                throw DependencyError.providerNotFound(type: T.self)
            }
        }
    }

    public func weakResolve<T>() throws -> T {
        let key = String(describing: T.self)
        return try queue.sync {
            if let weakBox = weakDependencies[key], let dependency = weakBox.value as? T {
                return dependency
            } else {
                throw DependencyError.providerNotFound(type: T.self)
            }
        }
    }

    public func register<T>(dependency: T) {
        let key = String(describing: T.self)
        queue.async(flags: .barrier) {
            self.strongDependencies[key] = dependency
        }
    }

    public func registerWeak<T: AnyObject>(dependency: T) {
        let key = String(describing: T.self)
        queue.async(flags: .barrier) {
            self.weakDependencies[key] = WeakBox(dependency)
        }
    }

    public func unregister<T>(type: T.Type) {
        let key = String(describing: T.self)
        queue.async(flags: .barrier) {
            self.strongDependencies.removeValue(forKey: key)
            self.weakDependencies.removeValue(forKey: key)
        }
    }

    public func unregisterAll() {
        queue.async(flags: .barrier) {
            self.strongDependencies.removeAll()
            self.weakDependencies.removeAll()
        }
    }
}

extension DependencyInjector {
    public static let shared = DependencyInjector()
}
