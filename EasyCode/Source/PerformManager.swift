//
//  PerformManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

/// A manager class to handle and perform asynchronous tasks.
public class PerformManager {

    /// Typealias for an asynchronous task.
    public typealias PerformTask = (() async -> Void)

    public private(set) var tasks = [PerformTask]()
    private var executionTask: Task<Void, Never>?

    public init() {}

    /// Adds a task to the manager's task list.
    /// - Parameter task: The asynchronous task to be added.
    ///
    /// # Example:
    /// ``` swift
    /// let performManager = PerformManager()
    ///
    /// performManager.addTask {
    ///     // Perform some async work here
    ///     await Task.sleep(1_000_000_000) // Sleep for 1 second
    ///     print("Task 1 completed")
    /// }
    ///
    /// let task2: PerformTask = {
    ///     // Perform some other async work here
    ///     await Task.sleep(2_000_000_000) // Sleep for 2 seconds
    ///     print("Task 2 completed")
    /// }
    ///
    /// performManager.addTask(task2)
    /// ```
    public func addTask(_ task: @escaping PerformTask) {
        tasks.append(task)
    }

    /// Cancels all tasks currently being executed or scheduled.
    ///
    /// # Example:
    /// ``` swift
    /// performManager.cancelAllTasks()
    /// ```
    public func cancelAllTasks() {
        executionTask?.cancel()
        executionTask = nil
        tasks.removeAll()
    }

    /// Performs the tasks in the manager's task list, either sequentially or concurrently.
    /// - Parameters:
    ///   - inSequence: A boolean indicating whether to perform tasks in sequence. Default is `false`, meaning tasks are performed concurrently.
    ///   - completion: An optional completion closure that is called when all tasks have been performed.
    ///
    /// # Example:
    /// ``` swift
    /// performManager.performTasks(inSequence: true) {
    ///     print("All tasks completed in sequence")
    /// }
    ///
    /// performManager.performTasks {
    ///     print("All tasks completed concurrently")
    /// }
    /// ```
    public func performTasks(inSequence: Bool = false, queue: DispatchQueue = .main, completion: (() -> Void)? = nil) {
        executionTask = Task(priority: .userInitiated) {
            if inSequence {
                for task in tasks {
                    await task()
                }
            } else {
                await withTaskGroup(of: Void.self) { group in
                    for task in tasks {
                        group.addTask {
                            await task()
                        }
                    }
                    await group.waitForAll()
                }
            }
            queue.async {
                completion?()
            }
        }
    }
}
