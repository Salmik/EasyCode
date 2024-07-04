//
//  BaseNotification.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit

public class NotificationAction: RawRepresentable, Equatable {

    public typealias RawValue = String

    public let rawValue: RawValue
    public var name: Notification.Name { .init(rawValue: rawValue) }

    required public init(rawValue: String = #function) {
        self.rawValue = rawValue
    }

    convenience public init(name: Notification.Name) {
        self.init(rawValue: name.rawValue)
    }
}

public extension NotificationAction {

    static var didBecomeActive: NotificationAction { .init(name: UIApplication.didBecomeActiveNotification) }
    static var willResignActive: NotificationAction { .init(name: UIApplication.willResignActiveNotification) }
    static var didEnterBackground: NotificationAction { .init(name: UIApplication.didEnterBackgroundNotification) }
    static var willEnterForeground: NotificationAction { .init(name: UIApplication.willEnterForegroundNotification) }
    static var screenCapturedDidChange: NotificationAction { .init(name: UIScreen.capturedDidChangeNotification) }
    static var keyboardWillShow: NotificationAction { .init(name: UIResponder.keyboardWillShowNotification) }
    static var keyboardWillHide: NotificationAction { .init(name: UIResponder.keyboardWillHideNotification) }
    static var didTakeScreenshot: NotificationAction { .init(name: UIApplication.userDidTakeScreenshotNotification) }
}
