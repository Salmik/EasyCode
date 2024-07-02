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
    func constraintToEdges(of view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
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
    func constraintToCenter(of view: UIView) -> [NSLayoutConstraint] {
        return makeConstraints { thisView in
            return [
                thisView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                thisView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        }
    }

    @discardableResult
    func constraintSize(to size: CGSize) -> [NSLayoutConstraint] {
        return makeConstraints { thisView in
            return [
                thisView.widthAnchor.constraint(equalToConstant: size.width),
                thisView.heightAnchor.constraint(equalToConstant: size.height)
            ]
        }
    }

    @discardableResult
    func constraintWidth(_ width: CGFloat) -> NSLayoutConstraint {
        return widthAnchor.constraint(equalToConstant: width).activate()
    }

    @discardableResult
    func constraintHeight(_ height: CGFloat) -> NSLayoutConstraint {
        return heightAnchor.constraint(equalToConstant: height).activate()
    }

    @discardableResult
    func pinTop(to value: CGFloat) -> Self {
        self.frame.origin.y = value
        return self
    }

    @discardableResult
    func pinLeft(to value: CGFloat) -> Self {
        self.frame.origin.x = value
        return self
    }

    @discardableResult
    func pinRight(to value: CGFloat) -> Self {
        guard let superview = self.superview else { return self }
        self.frame.origin.x = superview.frame.width - self.frame.width - value
        return self
    }

    @discardableResult
    func pinBottom(to value: CGFloat) -> Self {
        guard let superview = self.superview else { return self }
        self.frame.origin.y = superview.frame.height - self.frame.height - value
        return self
    }

    @discardableResult
    func setWidth(_ width: CGFloat) -> Self {
        self.frame.size.width = width
        return self
    }

    @discardableResult
    func setHeight(_ height: CGFloat) -> Self {
        self.frame.size.height = height
        return self
    }

    @discardableResult
    func centerX(to view: UIView) -> Self {
        self.frame.origin.x = (view.frame.width - self.frame.width) / 2
        return self
    }

    @discardableResult
    func centerY(to view: UIView) -> Self {
        self.frame.origin.y = (view.frame.height - self.frame.height) / 2
        return self
    }

    @discardableResult
    func center(to view: UIView) -> Self {
        return self.centerX(to: view).centerY(to: view)
    }

    @discardableResult
    func pinEdges(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        self.frame = CGRect(
            x: insets.left,
            y: insets.top,
            width: view.frame.width - insets.left - insets.right,
            height: view.frame.height - insets.top - insets.bottom
        )
        return self
    }
}
