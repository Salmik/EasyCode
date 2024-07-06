//
//  Observable.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

/// A generic observable class that allows observing changes to its value.
///
/// # Example:
/// ``` swift
/// // Example usage of Observable with Bool type
/// let isFinishedObservable = Observable(false)
///
/// // Binding a listener
/// isFinishedObservable.bind { isFinished in
///     if isFinished {
///         print("Task is finished!")
///     } else {
///         print("Task is in progress.")
///     }
/// }
///
/// // Changing the value
/// isFinishedObservable.value = true
/// ```
/// - Parameter value: The initial value.
public class Observable<T> {

    /// Defines a listener closure that takes a value of type `T`.
    public typealias Listener = (T) -> Void

    /// The closure to be called when the value changes.
    public var listener: Listener?

    /// The current value of the observable.
    public var value: T {
        didSet { listener?(value) }
    }

    /// Binds a listener closure to observe value changes.
    ///
    /// # Example:
    /// ``` swift
    /// // Example usage of Observable with String type
    /// let textObservable = Observable("Hello")
    ///
    /// // Binding a listener
    /// textObservable.bind { newText in
    ///     print("New text is: \(newText)")
    /// }
    ///
    /// // Changing the value
    /// textObservable.value = "Hello, world!"
    /// ```
    ///
    /// - Parameter listener: The closure to be called when the value changes.
    public func bind(listener: @escaping Listener) {
        self.listener = listener
        listener(value)
    }

    /// Initializes an observable with an initial value.
    public init(_ value: T) {
        self.value = value
    }
}
