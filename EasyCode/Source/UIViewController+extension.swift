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

    /// Returns the frame of the status bar.
    var statusBarFrame: CGRect? { UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame }

    /// Returns the frame of the application's main window.
    var windowFrame: CGRect? { UIApplication.shared.windows.first?.safeAreaLayoutGuide.layoutFrame }

    /// Returns the topmost visible view controller in the hierarchy.
    var topmostViewController: UIViewController { getTopmostViewControllerInChain(containing: self) }

    /// Checks if the view controller is presented modally.
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

    /// Retrieves the topmost view controller in the navigation chain containing the given view controller.
    ///
    /// # Example:
    /// ``` swift
    /// let topmostViewController = viewController.getTopmostViewControllerInChain(containing: self)
    /// ```
    ///
    /// - Parameter viewController: The view controller placed in the navigation chain.
    /// - Returns: The topmost view controller.
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

    /// Pushes a view controller onto the navigation stack with optional removal of the current controller.
    ///
    /// # Example:
    /// ``` swift
    /// self.push(viewController, removeCurrent: true, animated: true)
    /// ```
    ///
    /// - Parameters:
    ///   - viewController: The view controller to push onto the stack.
    ///   - removeCurrent: Whether to remove the current view controller after pushing.
    ///   - animated: Whether to animate the transition.
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

    /// Pushes a view controller onto the navigation stack and removes controllers at specific indices.
    ///
    /// Example:
    /// ```
    /// self.push(viewController, removeControllersWithIndices: [0, 1], animated: true)
    /// ```
    ///
    /// - Parameters:
    ///   - viewController: The view controller to push onto the stack.
    ///   - indices: Indices of controllers to remove from the navigation stack.
    ///   - animated: Whether to animate the transition.
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

    /// Pops view controllers from the navigation stack up to a specified view controller.
    ///
    /// # Example:
    /// ``` swift
    /// self.pop(to: anotherViewController, animated: true)
    /// ```
    ///
    /// - Parameters:
    ///   - viewController: The view controller to pop to. If `nil`, pops to the previous view controller.
    ///   - animated: Whether to animate the transition.
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

    /// Pops all view controllers from the navigation stack, leaving only the root view controller.
    ///
    /// # Example:
    /// ``` swift
    /// self.popToRoot(animated: true)
    /// ```
    ///
    /// - Parameter animated: Whether to animate the transition.
    func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }

    /// Presents a web page using SFSafariViewController.
    ///
    /// # Example:
    /// ``` swift
    /// self.presentWebPage(with: url)
    /// ```
    ///
    /// - Parameter url: The URL of the web page to present.
    func presentWebPage(with url: URL) {
        let sfSafariViewController = SFSafariViewController(url: url)
        present(sfSafariViewController, animated: true)
    }

    /// Presents a mail composer view controller with specified configuration.
    ///
    /// # Example:
    /// ``` swift
    /// self.presentMailPage(with: mailConfiguration)
    /// ```
    ///
    /// - Parameter configuration: The configuration for the mail composer.
    func presentMailPage(with configuration: MailConfiguration) {
        guard MFMailComposeViewController.canSendMail() else { return }

        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = self
        viewController.setSubject(configuration.subject)
        viewController.setToRecipients(configuration.recipients)
        viewController.setMessageBody(configuration.messageBody, isHTML: configuration.isBodyHtml)
        present(viewController, animated: true)
    }

    /// Presents a view controller with a right-to-left transition animation.
    ///
    /// # Example:
    /// ``` swift
    /// self.presentWithTransitionFromRight(viewController)
    /// ```
    ///
    /// - Parameter viewController: The view controller to present.
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

    /// Dismisses the view controller with a left-to-right transition animation.
    ///
    /// # Example:
    /// ``` swift
    /// self.dismissWithTransitionFromLeft()
    /// ```
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

    /// Saves an image to the device's photo gallery.
    ///
    /// # Example:
    /// ``` swift
    /// self.saveImageToGallery(image)
    /// ```
    ///
    /// - Parameter image: The image to save.
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

// MARK: - MFMailComposeViewControllerDelegate
extension UIViewController: MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    public func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}
