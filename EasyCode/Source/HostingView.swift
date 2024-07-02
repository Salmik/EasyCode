//
//  HostingView.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit
import SwiftUI

public class HostingView<T: View>: UIView {

    private(set) var hostingController: UIHostingController<T>

    public var rootView: T {
        get { hostingController.rootView }
        set { hostingController.rootView = newValue }
    }

    public init(rootView: T, frame: CGRect = .zero) {
        hostingController = UIHostingController(rootView: rootView)
        super.init(frame: frame)

        backgroundColor = .clear
        hostingController.view.backgroundColor = backgroundColor
        hostingController.view.frame = self.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(hostingController.view)
    }

    public func addChildControllerTo(_ controller: UIViewController) {
        controller.addChild(hostingController)
        hostingController.didMove(toParent: controller)
    }

    public func removeChildControllerTo(_ controller: UIViewController) {
        hostingController.willMove(toParent: nil)
        hostingController.removeFromParent()
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
