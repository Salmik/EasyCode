//
//  UIViewController+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit
import SafariServices
import MessageUI

public extension UIViewController {

    var statusBarFrame: CGRect? { UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame }

    var windowFrame: CGRect? { UIApplication.shared.windows.first?.safeAreaLayoutGuide.layoutFrame }

    /// (Visible) view controller placed at the top
    var topmostViewController: UIViewController { getTopmostViewControllerInChain(containing: self) }

    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }

    /// Get (visible) view controller placed at the top
    /// - Parameter viewController: view controller placed in chainisUnauthorized
    /// - Returns: view controller at the top
    func getTopmostViewControllerInChain(containing viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return getTopmostViewControllerInChain(containing: presentedViewController)
        } else if let navigationController = viewController as? UINavigationController {
            if let visibleViewController = navigationController.visibleViewController {
                return getTopmostViewControllerInChain(containing: visibleViewController)
            }
        } else if let tabBarController = viewController as? UITabBarController {
            if let selected = tabBarController.selectedViewController {
                return getTopmostViewControllerInChain(containing: selected)
            }
        }

        return viewController
    }

    /// Customized shortcut push method
    ///
    /// - Parameters:
    ///   - viewController: View controller to push to navigation stack
    ///   - removeCurrent: Remove currently displayed controller right after push
    ///   - animated: Perform push with animation
    func push(_ viewController: UIViewController, removeCurrent: Bool = false, animated: Bool = true) {
        defer {
            if removeCurrent,
               let controllers = navigationController?.viewControllers,
               let index = controllers.firstIndex(where: { $0 === self }) {
                navigationController?.viewControllers.remove(at: index)
            }
        }

        // Remove title from backBarButtonItem
        if let navigationController = self as? UINavigationController,
           let baseViewController = navigationController.visibleViewController {
            baseViewController.push(viewController, animated: animated)
            return
        }

        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        navigationItem.backBarButtonItem = backBarButtonItem
        navigationController?.pushViewController(viewController, animated: animated)
    }

    func push(_ viewController: UIViewController, removeControllersWithIndices indices: [Int], animated: Bool = true) {
        defer {
            if let navigationController = navigationController {
                var controllers = navigationController.viewControllers
                let filteredIndices: [Int] = Array(Set(indices)).sorted().reversed()
                for index in filteredIndices where 0..<controllers.count ~= index {
                    controllers.remove(at: index)
                }
                navigationController.setViewControllers(controllers, animated: false)
            }
        }

        // Remove title from backBarButtonItem
        if let navigationController = self as? UINavigationController,
           let baseViewController = navigationController.visibleViewController {
            baseViewController.push(viewController, animated: animated)
            return
        }

        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        navigationItem.backBarButtonItem = backBarButtonItem
        navigationController?.pushViewController(viewController, animated: animated)
    }

    func pop(to viewController: UIViewController? = nil, animated: Bool = true) {
        guard let navigationController = navigationController else { return }
        if let viewController = viewController {
            navigationController.popToViewController(viewController, animated: animated)
        } else {
            if let index = navigationController.viewControllers.firstIndex(where: { $0 == self }), index > 0 {
                let viewController = navigationController.viewControllers[index - 1]
                navigationController.popToViewController(viewController, animated: true)
            }
        }
    }

    func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }

    /// Show web page
    /// - Parameter url: url of the web page
    func presentWebPage(with url: URL) {
        let sfSafariViewController = SFSafariViewController(url: url)
        present(sfSafariViewController, animated: true)
    }

    func presentMailPage(with configuration: MailConfiguration) {
        guard MFMailComposeViewController.canSendMail() else { return }

        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = self
        viewController.setSubject(configuration.subject)
        viewController.setToRecipients(configuration.recipients)
        viewController.setMessageBody(configuration.messageBody, isHTML: configuration.isBodyHtml)
        present(viewController, animated: true)
    }

    func presentWithTransitionFromRight(_ viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeIn)
        view.window?.layer.add(transition, forKey: kCATransition)
        present(viewController, animated: false) { [unowned self] in
            self.view.window?.layer.removeAnimation(forKey: kCATransition)
        }
    }

    func dismissWithTransitionFromLeft() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .moveIn
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        view.window?.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false) { [unowned self] in
            self.view.window?.layer.removeAnimation(forKey: kCATransition)
        }
    }

    func saveImageToGallery(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc
    private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image successfully saved to gallery")
        }
    }
}

extension UIViewController: MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    public func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}
