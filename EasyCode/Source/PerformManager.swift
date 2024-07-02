//
//  PerformManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public class PerformManager {

    public typealias PerformTask = (() async -> Void)

    public private(set) var tasks = [PerformTask]()
    private var executionTask: Task<Void, Never>?

    public func addTask(_ task: @escaping PerformTask) {
        tasks.append(task)
    }

    public func cancelAllTasks() {
        executionTask?.cancel()
        executionTask = nil
        tasks.removeAll()
    }

    public func performTasks(inSequence: Bool = false, completion: (() -> Void)? = nil) {
        executionTask = Task(priority: .userInitiated) { @MainActor in
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
            completion?()
        }
    }
}
