//
//  NetworkGlobals.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 01.12.2024.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class NetworkGlobals {

    public static var isLoggerEnabled = true

    #if os(iOS)
    private static var popUpWindow: UIWindow?

    static let loggerViewController = LoggerTableViewController()

    static let loggerNavigationController = UINavigationController(rootViewController: loggerViewController)

    public static func presentLoggerOnNewWindow() {
        guard popUpWindow == nil else { return }
        let newWindow = UIWindow(frame: UIScreen.main.bounds)

        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            if let windowScene = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                newWindow.windowScene = windowScene
            } else {
                print("Не удалось найти активную windowScene.")
                return
            }
        }

        let backgroundViewController = UIViewController()
        backgroundViewController.view.backgroundColor = .clear
        newWindow.rootViewController = backgroundViewController
        newWindow.windowLevel = .alert + 1
        newWindow.makeKeyAndVisible()
        popUpWindow = newWindow

        DispatchQueue.main.async {
            loggerNavigationController.modalPresentationStyle = .overFullScreen
            backgroundViewController.present(loggerNavigationController, animated: true)
        }
    }

    public static func dismissWithNewWindow() {
        guard let window = popUpWindow,
              let presentedViewController = window.rootViewController?.presentedViewController else {
            return
        }
        presentedViewController.dismiss(animated: true) {
            Self.popUpWindow?.isHidden = true
            Self.popUpWindow = nil
        }
    }
    #endif
}
