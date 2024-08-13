//
//  DependencyFactory.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 12.08.2024.
//

import Foundation

/// A `DependencyFactory` is responsible for managing the lifecycle of instances in a dependency injection container.
/// It supports four types of lifecycles:
/// - `shared`: A singleton instance shared across the application.
/// - `weakShared`: A weakly referenced singleton, allowing the instance to be deallocated when not in use.
/// - `unshared`: A new instance created each time it's requested.
/// - `scoped`: An instance that is shared within a request but not retained afterwards.
open class DependencyFactory {

    /// A wrapper for weakly referenced instances to manage their lifecycle.
    private struct Weak<Instance: AnyObject> {
        weak var instance: Instance?

        init(_ instance: Instance) {
            self.instance = instance
        }
    }

    /// An enumeration defining the lifecycle of an instance.
    enum Lifecycle {
        case shared
        case weakShared
        case unshared
        case scoped
    }

    /// A key to uniquely identify instances by their lifecycle and name.
    struct InstanceKey: Hashable, CustomStringConvertible {

        let lifecycle: Lifecycle
        let name: String

        /// Provides a custom hash value for the key.
        func hash(into hasher: inout Hasher) {
            hasher.combine(lifecycle.hashValue ^ name.hashValue)
        }

        /// A string representation of the instance key.
        var description: String { "\(lifecycle)(\(name))" }

        /// Compares two instance keys for equality.
        static func == (lhs: InstanceKey, rhs: InstanceKey) -> Bool {
            return (lhs.lifecycle == rhs.lifecycle) && (lhs.name == rhs.name)
        }
    }

    private var sharedInstances: [String: Any] = [:]
    private var weakSharedInstances: [String: Any] = [:]
    private var scopedInstances: [String: Any] = [:]
    private var instanceStack: [InstanceKey] = []
    private var configureStack: [() -> Void] = []
    private var requestDepth = 0

    /// Initializes a new `DependencyFactory`.
    public init() { }

    /// Retrieves a shared instance or creates one if it does not exist.
    ///
    /// - Parameters:
    ///   - name: The name to identify the instance. Defaults to the function name.
    ///   - factory: A closure that creates the instance if it does not already exist.
    ///   - configure: An optional closure for additional configuration of the instance.
    /// - Returns: The shared instance.
    ///
    /// # Example:
    /// ```swift
    /// let factory = DependencyFactory()
    /// let sharedService = factory.shared { MyService() }
    /// ```
    public final func shared<T>(
        name: String = #function,
        factory: () -> T,
        configure: ((T) -> Void)? = nil
    ) -> T {
        return shared(name: name, factory(), configure: configure)
    }

    /// Retrieves a shared instance or creates one if it does not exist.
    ///
    /// - Parameters:
    ///   - name: The name to identify the instance. Defaults to the function name.
    ///   - factory: A closure that creates the instance if it does not already exist.
    ///   - configure: An optional closure for additional configuration of the instance.
    /// - Returns: The shared instance.
    ///
    /// # Example:
    /// ```swift
    /// let factory = DependencyFactory()
    /// let sharedService = shared(name: name, MyService())
    /// ```
    public final func shared<T>(
        name: String = #function,
        _ factory: @autoclosure () -> T,
        configure: ((T) -> Void)? = nil
    ) -> T {
        if let instance = sharedInstances[name] as? T {
            return instance
        }

        return inject(
            lifecycle: .shared,
            name: name,
            factory: factory,
            configure: configure
        )
    }

    /// Retrieves a weakly shared instance or creates one if it does not exist.
    ///
    /// - Parameters:
    ///   - name: The name to identify the instance. Defaults to the function name.
    ///   - factory: A closure that creates the instance if it does not already exist.
    ///   - configure: An optional closure for additional configuration of the instance.
    /// - Returns: The weakly shared instance.
    ///
    /// # Example:
    /// ```swift
    /// let factory = DependencyFactory()
    /// let weakSharedService = factory.weakShared { MyService() }
    /// ```
    public final func weakShared<T: AnyObject>(
        name: String = #function,
        factory: () -> T,
        configure: ((T) -> Void)? = nil
    ) -> T {
        return weakShared(name: name, factory(), configure: configure)
    }

    /// Retrieves a weakly shared instance or creates one if it does not exist.
    ///
    /// - Parameters:
    ///   - name: The name to identify the instance. Defaults to the function name.
    ///   - factory: A closure that creates the instance if it does not already exist.
    ///   - configure: An optional closure for additional configuration of the instance.
    /// - Returns: The weakly shared instance.
    ///
    /// # Example:
    /// ```swift
    /// let factory = DependencyFactory()
    /// let weakSharedService = factory.weakShared(name: name, MyService())
    /// ```
    public final func weakShared<T: AnyObject>(
        name: String = #function,
        _ factory: @autoclosure () -> T,
        configure: ((T) -> Void)? = nil
    ) -> T {
        if let weakInstance = weakSharedInstances[name] as? Weak<T> {
            if let instance = weakInstance.instance {
                return instance
            }
        }

        let instance: T = factory()
        let weakInstance: Weak<T> = inject(
            lifecycle: .weakShared,
            name: name,
            factory: {
                return Weak(instance)
            },
            configure: { weakInstance in
                if let strongInstance = weakInstance.instance {
                    configure?(strongInstance)
                }
            }
        )

        if let strongInstance = weakInstance.instance {
            return strongInstance
        } else {
            fatalError("Weak instance was not created properly.")
        }
    }

    /// Creates a new unshared instance each time it is requested.
    ///
    /// - Parameters:
    ///   - name: The name to identify the instance. Defaults to the function name.
    ///   - factory: A closure that creates a new instance.
    ///   - configure: An optional closure for additional configuration of the instance.
    /// - Returns: A new instance.
    ///
    /// # Example:
    /// ```swift
    /// let factory = DependencyFactory()
    /// let newServiceInstance = factory.unshared { MyService() }
    /// ```
    public final func unshared<T>(
        name: String = #function,
        factory: () -> T,
        configure: ((T) -> Void)? = nil
    ) -> T {
        return unshared(name: name, factory(), configure: configure)
    }

    /// Creates a new unshared instance each time it is requested.
    ///
    /// - Parameters:
    ///   - name: The name to identify the instance. Defaults to the function name.
    ///   - factory: A closure that creates a new instance.
    ///   - configure: An optional closure for additional configuration of the instance.
    /// - Returns: A new instance.
    ///
    /// # Example:
    /// ```swift
    /// let factory = DependencyFactory()
    /// let newServiceInstance = factory.unshared(name: name, MyService())
    /// ```
    public final func unshared<T>(
        name: String = #function,
        _ factory: @autoclosure () -> T,
        configure: ((T) -> Void)? = nil
    ) -> T {
        return inject(
            lifecycle: .unshared,
            name: name,
            factory: factory,
            configure: configure
        )
    }

    /// Retrieves a scoped instance or creates one if it does not exist.
    ///
    /// - Parameters:
    ///   - name: The name to identify the instance. Defaults to the function name.
    ///   - factory: A closure that creates the instance if it does not already exist.
    ///   - configure: An optional closure for additional configuration of the instance.
    /// - Returns: The scoped instance.
    ///
    /// # Example:
    /// ```swift
    /// let factory = DependencyFactory()
    /// let scopedService = factory.scoped { MyService() }
    /// ```
    public final func scoped<T>(
        name: String = #function,
        factory: () -> T,
        configure: ((T) -> Void)? = nil
    ) -> T {
        return scoped(name: name, factory(), configure: configure)
    }

    /// Retrieves a scoped instance or creates one if it does not exist.
    ///
    /// - Parameters:
    ///   - name: The name to identify the instance. Defaults to the function name.
    ///   - factory: A closure that creates the instance if it does not already exist.
    ///   - configure: An optional closure for additional configuration of the instance.
    /// - Returns: The scoped instance.
    ///
    /// # Example:
    /// ```swift
    /// let factory = DependencyFactory()
    /// let scopedService = factory.scoped(name: name, MyService())
    /// ```
    public final func scoped<T>(
        name: String = #function,
        _ factory: @autoclosure () -> T,
        configure: ((T) -> Void)? = nil
    ) -> T {
        if let instance = scopedInstances[name] as? T {
            return instance
        }

        return inject(
            lifecycle: .scoped,
            name: name,
            factory: factory,
            configure: configure
        )
    }

    /// A private method that handles the injection of instances based on their lifecycle.
    ///
    /// - Parameters:
    ///   - lifecycle: The lifecycle of the instance.
    ///   - name: The name of the instance.
    ///   - factory: A closure that creates the instance.
    ///   - configure: An optional closure for additional configuration of the instance.
    /// - Returns: The instance created or retrieved based on the lifecycle.
    private final func inject<T>(
        lifecycle: Lifecycle,
        name: String,
        factory: () -> T,
        configure: ((T) -> Void)?
    ) -> T {
        let key = InstanceKey(lifecycle: lifecycle, name: name)

        if lifecycle != .unshared && instanceStack.contains(key) {
            fatalError("Circular dependency from one of \(instanceStack) to \(key) in initializer")
        }

        instanceStack.append(key)
        let instance = factory()
        instanceStack.removeLast()

        switch lifecycle {
        case .shared:
            sharedInstances[name] = instance
        case .weakShared:
            weakSharedInstances[name] = instance
        case .unshared:
            break
        case .scoped:
            scopedInstances[name] = instance
        }

        if let configure = configure {
            configureStack.append({ configure(instance) })
        }

        if instanceStack.count == 0 {
            let delayedConfigures = configureStack
            configureStack.removeAll(keepingCapacity: true)

            requestDepth += 1

            for delayedConfigure in delayedConfigures {
                delayedConfigure()
            }

            requestDepth -= 1

            if requestDepth == 0 {
                scopedInstances.removeAll(keepingCapacity: true)
            }
        }

        return instance
    }
}
