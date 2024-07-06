//
//  NotificationManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

/// A protocol that defines the methods a delegate of `NotificationManager` should implement.
public protocol NotificationManagerDelegate: AnyObject {

    /// Called when a notification is triggered.
    ///
    /// - Parameters:
    ///   - notification: The notification action that was triggered.
    ///   - object: The object associated with the notification.
    ///   - userInfo: The user info dictionary associated with the notification.
    func performOnTrigger(_ notification: NotificationAction, object: Any?, userInfo: [AnyHashable: Any]?)
}

/// A class that manages subscriptions to notifications and triggers actions when notifications are posted.
public class NotificationManager {

    private let notificationCenter = NotificationCenter.default
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
    /// notificationManager.subscribe(to: .exampleNotification)
    /// ```
    public func subscribe(to notification: NotificationAction, object: Any? = nil) {
        notificationCenter.addObserver(self, selector: #selector(selector), name: notification.name, object: object)
    }

    /// Unsubscribes from a notification action.
    ///
    /// - Parameters:
    ///   - notification: The notification action to unsubscribe from.
    ///   - object: The object to disassociate from the subscription (optional).
    ///
    /// # Example:
    /// ``` swift
    /// notificationManager.unsubscribe(from: .exampleNotification)
    /// ```
    public func unsubscribe(from notification: NotificationAction, object: Any? = nil) {
        notificationCenter.removeObserver(self, name: notification.name, object: object)
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
    /// notificationManager.trigger(notification: .exampleNotification, userInfo: ["key": "value"])
    /// ```
    public func trigger(notification: NotificationAction, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        notificationCenter.post(name: notification.name, object: object, userInfo: userInfo)
    }

    /// A selector method called when a notification is triggered.
    ///
    /// - Parameter notification: The notification that was triggered.
    @objc private func selector(_ notification: Notification) {
        let baseNotification = NotificationAction(name: notification.name)
        delegate?.performOnTrigger(baseNotification, object: notification.object, userInfo: notification.userInfo)
    }
}
