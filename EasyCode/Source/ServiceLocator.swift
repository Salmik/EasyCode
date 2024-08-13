//
//  ServiceLocator.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 12.08.2024.
//

import Foundation

/// `ServiceLocator` is a class that provides a global access point to a service or factory, allowing the registration
/// and resolution of dependencies. It uses a singleton pattern to manage a shared instance and provides thread safety
/// using an `NSLock` to synchronize access to the internal factories dictionary.
///
/// # Example Usage:
/// ```swift
/// class Service {
///
///     func doSomething() {
///         print("Service is doing something.")
///     }
/// }
///
/// // Registering a Service instance in the container
/// let container = ServiceLocator.sharedInstance()
/// container.register(Service.self) { Service() }
///
/// // Resolving and using the Service instance
/// let service: Service = container.resolve(Service.self)
/// service.doSomething() // Output: "Service is doing something."
///
/// // Checking if the Service is registered in the container
/// if container.isDependencyExists(Service.self) {
///     print("Service is registered in the container.")
/// }
///
/// // Removing the Service instance from the container
/// container.remove(Service.self)
/// print("Service removed from container.")
///
/// // Releasing the singleton instance of ServiceLocator
/// ServiceLocator.releaseInstance()
/// ```
class ServiceLocator {

    /// A wrapper to hold an unmanaged reference to the `ServiceLocator` instance.
    static private var instanceWrapper: UnmanagedWrapper<ServiceLocator>?

    /// A dictionary to store the factories for creating instances of various types.
    private var factories = [String: Any]()

    /// A lock to ensure thread-safe access to the factories dictionary.
    private let lock = NSLock()

    /// Private initializer to prevent direct instantiation. Use `sharedInstance()` to get the singleton instance.
    private init() {}

    /// Returns the shared instance of `ServiceLocator`. If the instance does not exist, it creates and stores it.
    /// - Returns: The shared `ServiceLocator` instance.
    static func sharedInstance() -> ServiceLocator {
        if let instance = instanceWrapper?.getManagedInstance() {
            return instance
        } else {
            let newInstance = ServiceLocator()
            instanceWrapper = UnmanagedWrapper(newInstance)
            return newInstance
        }
    }

    /// Releases the current shared instance of `ServiceLocator` if it exists.
    static func releaseInstance() {
        instanceWrapper?.release()
        instanceWrapper = nil
    }

    /// Registers a factory closure that will be used to create instances of the specified type.
    /// - Parameters:
    ///   - type: The type to register a factory for.
    ///   - factory: A closure that returns an instance of the specified type.
    /// - Note: This method is thread-safe.
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        factories[key] = factory
    }

    /// Resolves an instance of the specified type by calling the registered factory closure.
    /// - Parameter type: The type to resolve an instance for.
    /// - Returns: An instance of the specified type.
    /// - Throws: A fatal error if no factory is registered for the specified type.
    /// - Note: This method is thread-safe.
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        guard let factory = factories[key] as? () -> T else {
            fatalError("No registered entry for \(key)")
        }
        return factory()
    }

    /// Checks if a factory for the specified type is registered.
    /// - Parameter type: The type to check for a registered factory.
    /// - Returns: A boolean value indicating whether a factory for the specified type exists.
    /// - Note: This method is thread-safe.
    func isDependencyExists<T: Any>(_ type: T.Type) -> Bool {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        return factories.keys.contains(key)
    }

    /// Removes the registered factory for the specified type.
    /// - Parameter type: The type to remove the registered factory for.
    /// - Note: This method is thread-safe.
    func remove<T>(_ type: T.Type) {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        factories.removeValue(forKey: key)
    }

    /// Removes all registered factories.
    /// - Note: This method is thread-safe.
    func removeAllDependencies() {
        lock.lock()
        defer { lock.unlock() }
        factories.removeAll()
    }
}
