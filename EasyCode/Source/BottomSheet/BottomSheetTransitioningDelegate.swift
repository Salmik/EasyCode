//
//  BottomSheetTransitioningDelegate.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 01.12.2024.
//

import UIKit

class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private let height: CGFloat?

    init(height: CGFloat? = nil) {
        self.height = height
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        return BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            height: height
        )
    }
}
