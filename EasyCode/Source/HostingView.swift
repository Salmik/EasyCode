//
//  HostingView.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit
import SwiftUI

/// A custom UIView subclass that hosts a SwiftUI view using UIHostingController.
///
/// This class provides functionality to manage the hosted SwiftUI view within a UIKit environment.
///
/// # Example:
/// ``` swift
/// struct ContentView: View {
///     var body: some View {
///         Text("Hello, SwiftUI!")
///     }
/// }
///
/// let hostingView = HostingView(rootView: ContentView())
/// // Add hostingView to your view hierarchy or a parent view controller
/// ```
public class HostingView<T: View>: UIView {

    /// The UIHostingController instance managing the SwiftUI view.
    public private(set) var hostingController: UIHostingController<T>

    /// The root SwiftUI view managed by the hosting controller.
    public var rootView: T {
        get { hostingController.rootView }
        set { hostingController.rootView = newValue }
    }

    /// Initializes a hosting view with a SwiftUI root view and a frame.
    ///
    /// - Parameters:
    ///   - rootView: The root SwiftUI view to host.
    ///   - frame: The initial frame rectangle for the hosting view, measured in points.
    public init(rootView: T, frame: CGRect = .zero) {
        hostingController = UIHostingController(rootView: rootView)
        super.init(frame: frame)

        backgroundColor = .clear
        hostingController.view.backgroundColor = backgroundColor
        hostingController.view.frame = self.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(hostingController.view)
    }

    /// Adds the hosting controller as a child of the specified view controller.
    ///
    /// - Parameter controller: The view controller to which the hosting controller should be added as a child.
    public func addChildControllerTo(_ controller: UIViewController) {
        controller.addChild(hostingController)
        hostingController.didMove(toParent: controller)
    }

    /// Removes the hosting controller from its parent view controller.
    ///
    /// - Parameter controller: The view controller from which the hosting controller should be removed.
    public func removeChildControllerTo(_ controller: UIViewController) {
        hostingController.willMove(toParent: nil)
        hostingController.removeFromParent()
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
