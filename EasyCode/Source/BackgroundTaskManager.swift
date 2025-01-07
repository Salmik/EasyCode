//
//  BackgroundTaskManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 07.01.2025.
//

import UIKit

public class BackgroundTaskManager {

    private var taskID: UIBackgroundTaskIdentifier = .invalid
    private weak var timeoutTimer: Timer?
    private let timeLimit: TimeInterval

    public init(timeLimit: TimeInterval = 28.0) {
        self.timeLimit = timeLimit
    }

    deinit { endTaskIfNeeded() }

    public func beginTask(
        backgroundQueue: DispatchQueue = .global(qos: .background),
        autoEndTask: Bool = true,
        onBegan: (() -> Void)? = nil,
        onExpiration: (() -> Void)? = nil
    ) {
        guard taskID == .invalid else { return }

        taskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            onExpiration?()
            self?.endTaskIfNeeded()
        }

        guard taskID != .invalid else { return }

        startTimeoutTimer()

        backgroundQueue.async { [weak self] in
            onBegan?()
            if autoEndTask {
                self?.endTaskIfNeeded()
            }
        }
    }

    public func endTaskIfNeeded() {
        guard taskID != .invalid else { return }

        UIApplication.shared.endBackgroundTask(taskID)
        taskID = .invalid

        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }

    private func startTimeoutTimer() {
        timeoutTimer?.invalidate()

        let timer = Timer.scheduledTimer(withTimeInterval: timeLimit, repeats: false) { [weak self] _ in
            self?.endTaskIfNeeded()
        }
        RunLoop.current.add(timer, forMode: .common)

        timeoutTimer = timer
    }
}
