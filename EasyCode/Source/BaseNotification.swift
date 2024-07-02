//
//  BaseNotification.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit

public class BaseNotification: RawRepresentable, Equatable {

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

public extension BaseNotification {

    static var didBecomeActive: BaseNotification { .init(name: UIApplication.didBecomeActiveNotification) }
    static var willResignActive: BaseNotification { .init(name: UIApplication.willResignActiveNotification) }
    static var didEnterBackground: BaseNotification { .init(name: UIApplication.didEnterBackgroundNotification) }
    static var willEnterForeground: BaseNotification { .init(name: UIApplication.willEnterForegroundNotification) }
    static var screenCapturedDidChange: BaseNotification { .init(name: UIScreen.capturedDidChangeNotification) }
    static var keyboardWillShow: BaseNotification { .init(name: UIResponder.keyboardWillShowNotification) }
    static var keyboardWillHide: BaseNotification { .init(name: UIResponder.keyboardWillHideNotification) }
}
