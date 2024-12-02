//
//  UIApplication+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.12.2024.
//

import UIKit

public extension UIApplication {

    var firstActiveScene: UIWindowScene? {
        guard let connectedScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }),
              let scene = connectedScene as? UIWindowScene else {
            return nil
        }

        return scene
    }

    var firstActiveWindow: UIWindow? {
        guard let scene = firstActiveScene, let window = scene.windows.first else { return nil }
        return window
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString), canOpenURL(url) else { return }
        open(url)
    }

    func dismissKeyboard() {
        sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}