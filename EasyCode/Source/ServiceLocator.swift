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
/// The `ServiceLocator` is designed to be a simple and thread-safe solution for managing dependencies in an application.
/// It allows you to register factory closures that create instances of specific types, resolve those instances when needed,
/// and remove them when they are no longer required. The class ensures that all operations are performed in a thread-safe manner.
/// 
/// # Example Usage:
/// ```swift
/// // Define a simple service class
/// class Service {
///     func doSomething() {
///         print("Service is doing something.")
///     }
/// }
/// 
/// // Obtain the singleton instance of ServiceLocator
/// let container = ServiceLocator.sharedInstance()
/// 
/// // Register a Service instance in the container
/// container.register(Service.self) { Service() }
/// 
/// // Resolve and use the Service instance
/// let service: Service = container.resolve(Service.self)
/// service.doSomething() // Output: "Service is doing something."
/// 
/// // Check if the Service is registered in the container
/// if container.isDependencyExists(Service.self) {
///     print("Service is registered in the container.")
/// }
/// 
/// // Remove the Service instance from the container
/// container.remove(Service.self)
/// print("Service removed from container.")
/// 
/// // Release the singleton instance of ServiceLocator
/// ServiceLocator.releaseInstance()
/// ```
/// 
/// The above example demonstrates how to register a service in the `ServiceLocator`, resolve it for use, check its existence,
/// remove it when no longer needed, and finally release the singleton instance of the `ServiceLocator`.
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
    ///
    /// This method is thread-safe and ensures that only one instance of `ServiceLocator` is created and used throughout
    /// the application's lifecycle.
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
    ///
    /// This method should be used to explicitly release the singleton instance of `ServiceLocator` when it is no longer needed.
    /// After calling this method, the next call to `sharedInstance()` will create a new instance.
    static func releaseInstance() {
        instanceWrapper?.release()
        instanceWrapper = nil
    }

    /// Registers a factory closure that will be used to create instances of the specified type.
    /// - Parameters:
    ///   - type: The type to register a factory for.
    ///   - factory: A closure that returns an instance of the specified type.
    ///
    /// This method allows you to register a factory for a specific type. The factory closure will be called whenever an
    /// instance of the registered type is needed. The method is thread-safe, ensuring that the registration process is
    /// protected from concurrent access.
    ///
    /// - Example:
    /// ```swift
    /// container.register(Service.self) { Service() }
    /// ```
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
    ///
    /// This method retrieves an instance of the specified type by invoking the registered factory closure. If no factory
    /// is registered for the given type, the method throws a fatal error. The method is thread-safe and ensures that
    /// the resolution process is protected from concurrent access.
    ///
    /// - Example:
    /// ```swift
    /// let service: Service = container.resolve(Service.self)
    /// ```
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
    ///
    /// This method allows you to check if a factory has been registered for a specific type. It returns `true` if a
    /// factory is found, otherwise it returns `false`. The method is thread-safe and ensures that the check is protected
    /// from concurrent access.
    ///
    /// - Example:
    /// ```swift
    /// if container.isDependencyExists(Service.self) {
    ///     print("Service is registered in the container.")
    /// }
    /// ```
    func isDependencyExists<T: Any>(_ type: T.Type) -> Bool {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        return factories.keys.contains(key)
    }

    /// Removes the registered factory for the specified type.
    /// - Parameter type: The type to remove the registered factory for.
    ///
    /// This method removes the factory closure registered for a specific type. If no factory is registered for the type,
    /// the method does nothing. The method is thread-safe and ensures that the removal process is protected from concurrent access.
    ///
    /// - Example:
    /// ```swift
    /// container.remove(Service.self)
    /// ```
    func remove<T>(_ type: T.Type) {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        factories.removeValue(forKey: key)
    }

    /// Removes all registered factories.
    ///
    /// This method removes all factory closures that have been registered in the `ServiceLocator`. After calling this method,
    /// no types can be resolved until new factories are registered. The method is thread-safe and ensures that the removal
    /// process is protected from concurrent access.
    ///
    /// - Example:
    /// ```swift
    /// container.removeAllDependencies()
    /// ```
    func removeAllDependencies() {
        lock.lock()
        defer { lock.unlock() }
        factories.removeAll()
    }
}
