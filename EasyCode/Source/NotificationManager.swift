//
//  NotificationManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public protocol NotificationManagerDelegate: AnyObject {

    func performOnTrigger(_ notification: NotificationAction, object: Any?, userInfo: [AnyHashable: Any]?)
}

public class NotificationManager {

    private let notificationCenter = NotificationCenter.default
    public weak var delegate: NotificationManagerDelegate?

    public init() {}

    public func subscribe(to notification: NotificationAction, object: Any? = nil) {
        notificationCenter.addObserver(self, selector: #selector(selector), name: notification.name, object: object)
    }

    public func unsubscribe(from notification: NotificationAction, object: Any? = nil) {
        notificationCenter.removeObserver(self, name: notification.name, object: object)
    }

    public func trigger(notification: NotificationAction, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        notificationCenter.post(name: notification.name, object: object, userInfo: userInfo)
    }

    @objc private func selector(_ notification: Notification) {
        let baseNotification = NotificationAction(name: notification.name)
        delegate?.performOnTrigger(baseNotification, object: notification.object, userInfo: notification.userInfo)
    }
}
