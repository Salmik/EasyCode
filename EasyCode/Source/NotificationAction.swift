//
//  BaseNotification.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit

public protocol NotificationKeyProtocol {

    var rawValue: String { get }
    var name: Notification.Name { get }
}

public enum NotificationAction: String, NotificationKeyProtocol {

    case didBecomeActive
    case willResignActive
    case didEnterBackground
    case willEnterForeground
    case screenCapturedDidChange
    case keyboardWillShow
    case keyboardWillHide
    case didTakeScreenshot
    case testNotification

    public var name: Notification.Name {
        switch self {
        case .keyboardWillShow:
            return UIResponder.keyboardWillShowNotification
        case .keyboardWillHide:
            return UIResponder.keyboardWillHideNotification
        case .didBecomeActive:
            return UIApplication.didBecomeActiveNotification
        case .willResignActive:
            return UIApplication.willResignActiveNotification
        case .didEnterBackground:
            return UIApplication.didEnterBackgroundNotification
        case .willEnterForeground:
            return UIApplication.willEnterForegroundNotification
        case .screenCapturedDidChange:
            return UIScreen.capturedDidChangeNotification
        case .didTakeScreenshot:
            return UIApplication.userDidTakeScreenshotNotification
        default:
            return Notification.Name(rawValue: self.rawValue)
        }
    }
}
