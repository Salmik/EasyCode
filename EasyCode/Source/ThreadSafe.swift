//
//  ThreadSafe.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

/// A thread-safe wrapper for any type `T`, ensuring that read and write operations are performed atomically.
///     
/// # Example:
/// ``` swift
/// let safeInt = ThreadSafe(0)
/// let safeArray = ThreadSafe([Int]())
/// let safeDictionary = ThreadSafe([String: Int]())
/// let dispatchGroup = DispatchGroup()
/// let queue = DispatchQueue(label: "com.example.threadSafeTest", attributes: .concurrent)
///
/// for i in 1...10 {
/// queue.async(group: dispatchGroup) {
///        safeInt.modify { value in
///            value += 1
///        }
///    }
/// }
///
/// for i in 1...10 {
///    queue.async(group: dispatchGroup) {
///        safeArray.modify { array in
///            array.append(i)
///        }
///    }
/// }
///
/// for i in 1...10 {
///    queue.async(group: dispatchGroup) {
///        safeDictionary.modify { dictionary in
///            dictionary["key\(i)"] = i
///        }
///    }
/// }
///
/// dispatchGroup.notify(queue: .main) {
///    print("Final integer value: \(safeInt.wrappedValue)")
///    print("Final array: \(safeArray.wrappedValue)")
///    print("Final dictionary: \(safeDictionary.wrappedValue)")
/// }
/// ```
public class ThreadSafe<T> {

    private var value: T
    private let lock = NSLock()

    /// Initializes the `ThreadSafe` instance with an initial value.
    /// - Parameter value: The initial value to be wrapped.
    ///
    /// # Example:
    /// ``` swift
    /// let threadSafeInt = ThreadSafe(0)
    /// ```
    public init(_ value: T) {
        self.value = value
    }

    /// The wrapped value, providing thread-safe access for both getting and setting the value.
    ///
    /// # Example:
    /// ``` swift
    /// var safeInt = ThreadSafe(0)
    /// safeInt.wrappedValue = 10
    /// print(safeInt.wrappedValue) // Output: 10
    /// ```
    public var wrappedValue: T {
        get {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            self.value = newValue
        }
    }

    /// Modifies the wrapped value in a thread-safe manner.
    /// - Parameter modify: A closure that modifies the value in place.
    ///
    /// # Example:
    /// ``` swift
    /// var safeArray = ThreadSafe([1, 2, 3])
    /// safeArray.modify { array in
    ///     array.append(4)
    ///     array[0] = 10
    /// }
    /// print(safeArray.read { $0 }) // Output: [10, 2, 3, 4]
    /// ```
    public func modify(_ modify: (inout T) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        modify(&value)
    }

    /// Reads the wrapped value in a thread-safe manner and returns a result derived from the value.
    /// - Parameter read: A closure that takes the value as a parameter and returns a result.
    /// - Returns: The result derived from the value.
    ///
    /// # Example:
    /// ``` swift
    /// let currentValue = safeInt.read { $0 }
    /// print(currentValue) // Output: current value of the wrapped integer
    /// ```
    public func read<R>(_ read: (T) -> R) -> R {
        lock.lock()
        defer { lock.unlock() }
        return read(value)
    }
}
