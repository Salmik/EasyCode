//
//  DispatchWorker.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public class DispatchWorker {

    /// Typealias for the closure executed when `execute` function is called.
    public typealias ExecuteClosure = () -> Void

    /// Typealias for the closure executed when `update` function is called.
    public typealias UpdateClosure = () -> Void

    /// Executes the provided closure on the specified dispatch queue with an optional delay and update closure.
    ///
    /// - Parameters:
    ///   - queue: The dispatch queue on which to execute the closure.
    ///   - updateDelay: Optional delay in milliseconds before executing the closure.
    ///   - execute: The closure to be executed on the dispatch queue.
    ///   - update: Optional closure to be executed on the main queue after the main closure.
    ///
    /// # Example:
    /// ``` swift
    /// let workQueue = DispatchQueue(label: "com.example.workqueue")
    ///
    /// // Example 1: Execute immediately on the specified queue
    /// DispatchWorker.execute(on: workQueue) {
    ///     print("Executing work on custom queue")
    /// }
    ///
    /// // Example 2: Execute after a delay of 500 milliseconds on the specified queue
    /// DispatchWorker.execute(on: workQueue, updateDelay: 500) {
    ///     print("Executing work with a 500ms delay")
    /// } update: {
    ///     print("Update after work execution")
    /// }
    /// ```
    public class func execute(
        on queue: DispatchQueue,
        updateDelay milliseconds: Int? = nil,
        execute: @escaping ExecuteClosure,
        update: UpdateClosure? = nil
    ) {
        if let milliseconds = milliseconds {
            let delayInterval = DispatchTimeInterval.milliseconds(milliseconds)
            queue.asyncAfter(deadline: .now() + delayInterval) {
                execute()
                if let update = update {
                    DispatchQueue.main.async(execute: update)
                }
            }
        } else {
            queue.async {
                execute()
                if let update = update {
                    DispatchQueue.main.async(execute: update)
                }
            }
        }
    }
}
