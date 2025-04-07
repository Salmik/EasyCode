//
//  BottomSheetPresentationController.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 01.12.2024.
//

import UIKit

class BottomSheetPresentationController: UIPresentationController {

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()
    private let drawerLineView = DrawerLineView()

    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var initialTranslationY: CGFloat = 0

    private let customHeight: CGFloat?

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        height: CGFloat? = nil
    ) {
        self.customHeight = height
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView, let presentedView else { return }

        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0
        containerView.addSubview(dimmingView)

        presentedView.layer.cornerRadius = 24
        presentedView.layer.masksToBounds = true
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        dimmingView.addGestureRecognizer(tapGesture)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        presentedView.addGestureRecognizer(panGestureRecognizer)
        self.panGestureRecognizer = panGestureRecognizer

        let lineHeight: CGFloat = 5
        let lineWidth: CGFloat = 40
        let lineX = (containerView.bounds.width - lineWidth) / 2

        drawerLineView.frame = CGRect(x: lineX, y: -lineHeight, width: lineWidth, height: lineHeight)
        presentedView.addSubview(drawerLineView)

        let topInset = drawerLineView.frame.maxY + 24
        presentedViewController.additionalSafeAreaInsets.top = topInset

        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1.0
                presentedView.frame = self.frameOfPresentedViewInContainerView
                self.drawerLineView.frame.origin.y = 12
            }, completion: nil)
        } else {
            dimmingView.alpha = 1.0
            presentedView.frame = frameOfPresentedViewInContainerView
            drawerLineView.frame.origin.y = 12
        }
    }

    override func dismissalTransitionWillBegin() {
        animateDimmingViewAlpha(to: 0.0)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
            drawerLineView.removeFromSuperview()
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }

        let containerBounds = containerView.bounds
        let topSafeAreaInset = containerView.safeAreaInsets.top + drawerLineView.frame.height + 16
        let maxHeight = containerBounds.height - topSafeAreaInset

        let targetWidth = containerBounds.width

        let height: CGFloat
        if let customHeight {
            height = min(customHeight, maxHeight)
        } else {
            let fittingSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
            let size = presentedViewController.view.systemLayoutSizeFitting(
                fittingSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            height = min(size.height, maxHeight)
        }

        let yPosition = containerBounds.height - height
        let frame = CGRect(
            x: 0,
            y: yPosition,
            width: containerBounds.width,
            height: height
        )

        return frame
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let presentedView, let containerView else { return }

        presentedView.frame = frameOfPresentedViewInContainerView

        let lineWidth: CGFloat = 40
        let lineHeight: CGFloat = 5
        let lineX = (containerView.bounds.width - lineWidth) / 2

        drawerLineView.frame = CGRect(x: lineX, y: 12, width: lineWidth, height: lineHeight)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let presentedView else { return }

        let translation = gesture.translation(in: containerView)
        let velocity = gesture.velocity(in: containerView)

        switch gesture.state {
        case .began:
            initialTranslationY = presentedView.frame.origin.y
        case .changed:
            if translation.y > 0 {
                let newY = initialTranslationY + translation.y
                presentedView.frame.origin.y = newY
                updateDrawerLinePosition(for: newY)
            }
        case .ended, .cancelled:
            let threshold = presentedView.frame.height / 2
            if translation.y > threshold || velocity.y > 1000 {
                presentedViewController.dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                    self.presentedView?.frame = self.frameOfPresentedViewInContainerView
                    self.updateDrawerLinePosition(for: self.frameOfPresentedViewInContainerView.origin.y)
                })
            }
        default:
            break
        }
    }

    private func updateDrawerLinePosition(for yPosition: CGFloat) {
        guard let containerView else { return }

        let lineHeight: CGFloat = 5
        let lineWidth: CGFloat = 40
        let lineX = ((containerView.bounds.width - lineWidth) / 2).rounded()
        drawerLineView.frame = CGRect(x: ceil(lineX), y: 12, width: lineWidth, height: lineHeight)
    }

    private func animateDimmingViewAlpha(to alpha: CGFloat) {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = alpha
            drawerLineView.alpha = alpha
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = alpha
            self.drawerLineView.alpha = alpha
        })
    }
}
