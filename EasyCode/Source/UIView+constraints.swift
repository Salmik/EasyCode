//
//  UIView+constraints.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit

public extension UIView {

    @discardableResult
    func makeConstraints(_ closure: (UIView) -> [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = closure(self)
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    func findConstraint(relatedTo view: UIView, attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        return constraints.first { constraint in
            return (constraint.firstItem as? UIView == self || constraint.secondItem as? UIView == self) &&
                   (constraint.firstItem as? UIView == view || constraint.secondItem as? UIView == view) &&
                   constraint.firstAttribute == attribute
        }
    }

    func updateConstraint(relatedTo view: UIView, attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        if let constraint = findConstraint(relatedTo: view, attribute: attribute) {
            constraint.constant = constant
        }
    }

    func deactivateConstraint(relatedTo view: UIView, attribute: NSLayoutConstraint.Attribute) {
        if let constraint = findConstraint(relatedTo: view, attribute: attribute) {
            constraint.isActive = false
        }
    }

    func activateConstraint(relatedTo view: UIView, attribute: NSLayoutConstraint.Attribute) {
        if let constraint = findConstraint(relatedTo: view, attribute: attribute) {
            constraint.isActive = true
        }
    }

    @discardableResult
    func constrainToEdges(of view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        return makeConstraints { thisView in
            return [
                thisView.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
                thisView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
                thisView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
                thisView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right)
            ]
        }
    }

    @discardableResult
    func constrainToCenter(of view: UIView) -> [NSLayoutConstraint] {
        return makeConstraints { thisView in
            return [
                thisView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                thisView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        }
    }

    @discardableResult
    func constrainSize(to size: CGSize) -> [NSLayoutConstraint] {
        return makeConstraints { thisView in
            return [
                thisView.widthAnchor.constraint(equalToConstant: size.width),
                thisView.heightAnchor.constraint(equalToConstant: size.height)
            ]
        }
    }

    @discardableResult
    func constrainWidth(_ width: CGFloat) -> NSLayoutConstraint {
        return widthAnchor.constraint(equalToConstant: width).activate()
    }

    @discardableResult
    func constrainHeight(_ height: CGFloat) -> NSLayoutConstraint {
        return heightAnchor.constraint(equalToConstant: height).activate()
    }
}
