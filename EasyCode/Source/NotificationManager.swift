//
//  NotificationManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import Combine

/// A protocol that defines the methods a delegate of `NotificationManager` should implement.
public protocol NotificationManagerDelegate: AnyObject {

    /// Called when a notification is triggered.
    ///
    /// - Parameters:
    ///   - notification: The notification action that was triggered.
    ///   - object: The object associated with the notification.
    ///   - userInfo: The user info dictionary associated with the notification.
    func performOnTrigger(_ notification: NotificationKeyProtocol, object: Any?, userInfo: [AnyHashable: Any]?)
}

/// A class that manages subscriptions to notifications and triggers actions when notifications are posted.
public class NotificationManager {

    private var subscriptions = [Notification.Name: AnyCancellable]()
    public weak var delegate: NotificationManagerDelegate?

    public init() {}

    /// Subscribes to a notification action.
    ///
    /// - Parameters:
    ///   - notification: The notification action to subscribe to.
    ///   - object: The object to associate with the subscription (optional).
    ///
    /// # Example:
    /// ``` swift
    /// notificationManager.subscribe(to: NotificationEnum.exampleNotification)
    /// ```
    public func subscribe(to notification: NotificationKeyProtocol) {
        let cancellable = NotificationCenter.default.publisher(for: notification.name)
            .sink { [weak self] updatedNotification in
                self?.delegate?.performOnTrigger(
                    notification,
                    object: updatedNotification.object,
                    userInfo: updatedNotification.userInfo
                )
            }
        subscriptions[notification.name] = cancellable
    }

    /// Unsubscribes from a notification action.
    ///
    /// - Parameters:
    ///   - notification: The notification action to unsubscribe from.
    ///   - object: The object to disassociate from the subscription (optional).
    ///
    /// # Example:
    /// ``` swift
    /// notificationManager.unsubscribe(from: NotificationEnum.exampleNotification)
    /// ```
    public func unsubscribe(from notification: NotificationKeyProtocol) {
        guard let cancellable = subscriptions[notification.name] else { return }
        cancellable.cancel()
        subscriptions.removeValue(forKey: notification.name)
    }

    /// Triggers a notification action.
    ///
    /// - Parameters:
    ///   - notification: The notification action to trigger.
    ///   - object: The object to associate with the notification (optional).
    ///   - userInfo: The user info dictionary to associate with the notification (optional).
    ///
    /// # Example:
    /// ``` swift
    /// notificationManager.trigger(notification: NotificationEnum.exampleNotification, userInfo: ["key": "value"])
    /// ```
    public func trigger(
        notification: NotificationKeyProtocol,
        object: Any? = nil,
        userInfo: [AnyHashable: Any]? = nil
    ) {
        NotificationCenter.default.post(
            name: notification.name,
            object: object as AnyObject,
            userInfo: userInfo
        )
    }
}
