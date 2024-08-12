//
//  KeyboardNotificationProtocol.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation
import UIKit

public protocol KeyboardNotificationProtocol: NotificationManagerDelegate where Self: UIViewController {

    var notificationManager: NotificationManager { get }
    var scrollView: UIScrollView { get }

    func subscribeForKeyboardNotifications()
    func unsubscribeFromKeyboardNotifications()
}

public extension KeyboardNotificationProtocol {

    /// Subscribes to keyboard notifications including keyboard show and hide events.
    ///
    /// # Example:
    /// ``` swift
    /// class MyViewController: UIViewController, KeyboardNotificationProtocol {
    ///     var notificationManager: NotificationManager = NotificationManager()
    ///     var scrollView: UIScrollView = UIScrollView()
    ///
    ///     override func viewDidLoad() {
    ///         super.viewDidLoad()
    ///         subscribeForKeyboardNotifications()
    ///     }
    /// }
    /// ```
    func subscribeForKeyboardNotifications() {
        notificationManager.subscribe(to: .keyboardWillShow)
        notificationManager.subscribe(to: .keyboardWillHide)
        notificationManager.delegate = self
    }

    /// Unsubscribes from keyboard notifications.
    ///
    /// # Example:
    /// ``` swift
    /// class MyViewController: UIViewController, KeyboardNotificationProtocol {
    ///     var notificationManager: NotificationManager = NotificationManager()
    ///     var scrollView: UIScrollView = UIScrollView()
    ///
    ///     deinit { unsubscribeFromKeyboardNotifications() }
    /// }
    /// ```
    func unsubscribeFromKeyboardNotifications() {
        notificationManager.unsubscribe(from: .keyboardWillShow)
        notificationManager.unsubscribe(from: .keyboardWillHide)
    }

    private func scrollToFrameIfNeeded(keyboardFrame: CGRect) {
        scrollView.contentInset.bottom = keyboardFrame.height
    }

    private func resetScrollViewOffset() {
        scrollView.contentInset.bottom = .zero
    }
}

public extension KeyboardNotificationProtocol {

    func performOnTrigger(_ notification: NotificationAction, object: Any?, userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        switch notification {
        case .keyboardWillShow: scrollToFrameIfNeeded(keyboardFrame: frame.cgRectValue)
        case .keyboardWillHide: resetScrollViewOffset()
        default: return
        }
    }
}
