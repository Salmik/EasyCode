//
//  DebounceProvider.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

/// Provides a debounce mechanism for delaying function calls.
public class DebounceProvider<T> {

    public typealias UpdateClosure = (_ object: T) -> Void
    public typealias DebounceClosure = () -> Void

    /// Provides a mechanism for debouncing updates with a specified delay.
    ///
    /// - Parameters:
    ///   - milliseconds: The time interval in milliseconds to wait before firing the update closure.
    ///   - queue: The dispatch queue on which to perform the debounce operation.
    ///   - performWhileDebounce: Optional closure to perform actions while debounce is active.
    ///   - update: The closure to be debounced, which updates an object of type `T`.
    /// - Returns: A debounced update closure for the given parameters.
    ///
    /// # Example usage:
    ///
    /// ```swift
    /// let debounceClosure = DebounceProvider.debounce(milliseconds: 500, queue: DispatchQueue.main) { stringValue in
    ///     print("Debounced action performed with string: \(stringValue)")
    /// }
    ///
    /// // Call debounceClosure when needed to debounce an update.
    /// debounceClosure("Hello, world!")
    /// ```
    /// ```swift
    /// let debounceClosure = DebounceProvider.debounce(milliseconds: 500, queue: DispatchQueue.main) {
    ///     print("Debounced action performed")
    /// }
    ///
    /// // Call debounceClosure when needed to debounce an update.
    /// debounceClosure()
    /// ```
    ///
    public static func debounce(
        milliseconds: Int,
        queue: DispatchQueue,
        performWhileDebounce: @escaping DebounceClosure = {},
        update: @escaping UpdateClosure
    ) -> UpdateClosure {

        var lastFireTime = DispatchTime.now()
        let dispatchDelayInterval = DispatchTimeInterval.milliseconds(milliseconds)

        return { object in
            lastFireTime = DispatchTime.now()
            let dispatchTime = DispatchTime.now() + dispatchDelayInterval
            queue.asyncAfter(deadline: dispatchTime) {
                let interval = lastFireTime + dispatchDelayInterval
                let presentTime = DispatchTime.now()
                performWhileDebounce()
                if presentTime.rawValue >= interval.rawValue {
                    update(object)
                }
            }
        }
    }
}
