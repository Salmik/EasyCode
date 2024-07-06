//
//  UnmanagedWrapper.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import Foundation

/// A class that wraps an unmanaged reference to an object of type `T`.
///
/// - Parameters:
///   - T: The type of the object to be managed. Must be a class type.
///
/// # Example:
/// ``` swift
/// class MyClass {}
///
/// let instance = MyClass()
/// let wrapper = UnmanagedWrapper(instance)
///
/// if let managedInstance = wrapper.getManagedInstance() {
///     print("Managed instance: \(managedInstance)")
/// }
///
/// if let opaquePointer = wrapper.toOpaque() {
///     print("Opaque pointer: \(opaquePointer)")
/// }
///
/// wrapper.release()
/// ```
public class UnmanagedWrapper<T: AnyObject> {

    private var unmanaged: Unmanaged<T>?

    public init(_ instance: T) {
        self.unmanaged = Unmanaged.passRetained(instance)
    }

    /// Returns the managed instance of type `T`.
    ///
    /// - Returns: The managed instance, or `nil` if the instance has been released.
    ///
    public func getManagedInstance() -> T? {
        return unmanaged?.takeUnretainedValue()
    }

    /// Returns the unmanaged instance as an opaque pointer.
    ///
    /// - Returns: An `UnsafeMutableRawPointer` representing the unmanaged instance, or `nil` if the instance has been released.
    ///
    public func toOpaque() -> UnsafeMutableRawPointer? {
        return unmanaged?.toOpaque()
    }

    /// Releases the managed instance.
    public func release() {
        unmanaged?.release()
        unmanaged = nil
    }

    deinit {
        if unmanaged != nil {
            unmanaged?.release()
        }
    }
}
