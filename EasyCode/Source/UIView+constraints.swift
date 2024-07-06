//
//  UIView+constraints.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit

public extension UIView {

    /// Apply Auto Layout constraints to the view and activate them.
    ///
    /// # Example:
    /// ``` swift
    /// let view = UIView()
    /// let subview = UIView()
    /// view.addSubview(subview)
    /// let constraints = subview.makeConstraints { subview in
    ///     return [
    ///         subview.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
    ///         subview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
    ///         subview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
    ///         subview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
    ///     ]
    /// }
    /// ```
    ///
    /// - Parameter closure: A closure that returns an array of NSLayoutConstraint objects.
    /// - Returns: An array of activated NSLayoutConstraint objects.
    @discardableResult
    func makeConstraints(_ closure: (UIView) -> [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = closure(self)
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    /// Finds a specific NSLayoutConstraint related to another view and attribute.
    ///
    /// # Example:
    /// ``` swift
    /// let constraint = view.findConstraint(relatedTo: anotherView, attribute: .top)
    /// ```
    ///
    /// - Parameters:
    ///   - view: The related view to find the constraint.
    ///   - attribute: The attribute of the constraint to find.
    /// - Returns: The NSLayoutConstraint object if found, otherwise `nil`.
    func findConstraint(relatedTo view: UIView, attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        return constraints.first { constraint in
            return (constraint.firstItem as? UIView == self || constraint.secondItem as? UIView == self) &&
                   (constraint.firstItem as? UIView == view || constraint.secondItem as? UIView == view) &&
                   constraint.firstAttribute == attribute
        }
    }

    /// Updates the constant value of a NSLayoutConstraint related to another view and attribute.
    ///
    /// # Example:
    /// ``` swift
    /// view.updateConstraint(relatedTo: anotherView, attribute: .width, constant: 100)
    /// ```
    ///
    /// - Parameters:
    ///   - view: The related view of the constraint to update.
    ///   - attribute: The attribute of the constraint to update.
    ///   - constant: The new constant value for the constraint.
    func updateConstraint(relatedTo view: UIView, attribute: NSLayoutConstraint.Attribute, constant: CGFloat) {
        if let constraint = findConstraint(relatedTo: view, attribute: attribute) {
            constraint.constant = constant
        }
    }

    /// Deactivates a NSLayoutConstraint related to another view and attribute.
    ///
    /// # Example:
    /// ``` swift
    /// view.deactivateConstraint(relatedTo: anotherView, attribute: .height)
    /// ```
    ///
    /// - Parameters:
    ///   - view: The related view of the constraint to deactivate.
    ///   - attribute: The attribute of the constraint to deactivate.
    func deactivateConstraint(relatedTo view: UIView, attribute: NSLayoutConstraint.Attribute) {
        if let constraint = findConstraint(relatedTo: view, attribute: attribute) {
            constraint.isActive = false
        }
    }

    /// Activates a NSLayoutConstraint related to another view and attribute.
    ///
    /// # Example:
    /// ``` swift
    /// view.activateConstraint(relatedTo: anotherView, attribute: .centerX)
    /// ```
    ///
    /// - Parameters:
    ///   - view: The related view of the constraint to activate.
    ///   - attribute: The attribute of the constraint to activate.
    func activateConstraint(relatedTo view: UIView, attribute: NSLayoutConstraint.Attribute) {
        if let constraint = findConstraint(relatedTo: view, attribute: attribute) {
            constraint.isActive = true
        }
    }

    /// Constrains the view edges to match another view's edges with optional insets.
    ///
    /// # Example:
    /// ``` swift
    /// let constraints = view.constraintToEdges(of: anotherView, insets: .init(top: 10, left: 10, bottom: 10, right: 10))
    /// ```
    ///
    /// - Parameters:
    ///   - view: The view to match edges with.
    ///   - insets: The edge insets for the constraint. Default is zero.
    /// - Returns: An array of activated NSLayoutConstraint objects.
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

    /// Centers the view inside another view.
    ///
    /// # Example:
    /// ``` swift
    /// let constraints = view.constraintToCenter(of: anotherView)
    /// ```
    ///
    /// - Parameter view: The view to center inside.
    /// - Returns: An array of activated NSLayoutConstraint objects.
    @discardableResult
    func constraintToCenter(of view: UIView) -> [NSLayoutConstraint] {
        return makeConstraints { thisView in
            return [
                thisView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                thisView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        }
    }

    /// Constrains the view to a specific size.
    ///
    /// # Example:
    /// ``` swift
    /// let constraints = view.constraintSize(to: CGSize(width: 100, height: 100))
    /// ```
    ///
    /// - Parameter size: The size to constrain the view.
    /// - Returns: An array of activated NSLayoutConstraint objects.
    @discardableResult
    func constraintSize(to size: CGSize) -> [NSLayoutConstraint] {
        return makeConstraints { thisView in
            return [
                thisView.widthAnchor.constraint(equalToConstant: size.width),
                thisView.heightAnchor.constraint(equalToConstant: size.height)
            ]
        }
    }

    /// Constrains the view's width to a specific value.
    ///
    /// # Example:
    /// ``` swift
    /// let constraint = view.constraintWidth(200)
    /// ```
    ///
    /// - Parameter width: The width value to constrain.
    /// - Returns: The activated NSLayoutConstraint object.
    @discardableResult
    func constraintWidth(_ width: CGFloat) -> NSLayoutConstraint {
        return widthAnchor.constraint(equalToConstant: width).activate()
    }

    /// Constrains the view's height to a specific value.
    ///
    /// # Example:
    /// ``` swift
    /// let constraint = view.constraintHeight(50)
    /// ```
    ///
    /// - Parameter height: The height value to constrain.
    /// - Returns: The activated NSLayoutConstraint object.
    @discardableResult
    func constraintHeight(_ height: CGFloat) -> NSLayoutConstraint {
        return heightAnchor.constraint(equalToConstant: height).activate()
    }

    /// Pins the view's top edge to a specific value.
    ///
    /// # Example:
    /// ``` swift
    /// view.pinTop(to: 20)
    /// ```
    ///
    /// - Parameter value: The top edge value to pin.
    /// - Returns: Self for chaining.
    @discardableResult
    func pinTop(to value: CGFloat) -> Self {
        frame.origin.y = value
        return self
    }

    /// Pins the view's left edge to a specific value.
    ///
    /// # Example:
    /// ``` swift
    /// view.pinLeft(to: 10)
    /// ```
    ///
    /// - Parameter value: The left edge value to pin.
    /// - Returns: Self for chaining.
    @discardableResult
    func pinLeft(to value: CGFloat) -> Self {
        frame.origin.x = value
        return self
    }

    /// Pins the view's right edge to a specific value.
    ///
    /// # Example:
    /// ``` swift
    /// view.pinRight(to: 10)
    /// ```
    ///
    /// - Parameter value: The right edge value to pin.
    /// - Returns: Self for chaining.
    @discardableResult
    func pinRight(to value: CGFloat) -> Self {
        guard let superview else { return self }
        frame.origin.x = superview.frame.width - self.frame.width - value
        return self
    }

    /// Pins the view's bottom edge to a specific value.
    ///
    /// # Example:
    /// ``` swift
    /// view.pinBottom(to: 20)
    /// ```
    ///
    /// - Parameter value: The bottom edge value to pin.
    /// - Returns: Self for chaining.
    @discardableResult
    func pinBottom(to value: CGFloat) -> Self {
        guard let superview else { return self }
        frame.origin.y = superview.frame.height - self.frame.height - value
        return self
    }

    /// Sets the view's width to a specific value.
    ///
    /// # Example:
    /// ``` swift
    /// view.setWidth(100)
    /// ```
    ///
    /// - Parameter width: The width value to set.
    /// - Returns: Self for chaining.
    @discardableResult
    func setWidth(_ width: CGFloat) -> Self {
        frame.size.width = width
        return self
    }

    /// Sets the view's height to a specific value.
    ///
    /// # Example:
    /// ``` swift
    /// view.setHeight(50)
    /// ```
    ///
    /// - Parameter height: The height value to set.
    /// - Returns: Self for chaining.
    @discardableResult
    func setHeight(_ height: CGFloat) -> Self {
        frame.size.height = height
        return self
    }

    /// Centers the view horizontally relative to another view.
    ///
    /// # Example:
    /// ``` swift
    /// view.centerX(to: anotherView)
    /// ```
    ///
    /// - Parameter view: The view to center horizontally relative to.
    /// - Returns: Self for chaining.
    @discardableResult
    func centerX(to view: UIView) -> Self {
        frame.origin.x = (view.frame.width - frame.width) / 2
        return self
    }

    /// Centers the view vertically relative to another view.
    ///
    /// # Example:
    /// ``` swift
    /// view.centerY(to: anotherView)
    /// ```
    ///
    /// - Parameter view: The view to center vertically relative to.
    /// - Returns: Self for chaining.
    @discardableResult
    func centerY(to view: UIView) -> Self {
        frame.origin.y = (view.frame.height - frame.height) / 2
        return self
    }

    /// Centers the view both horizontally and vertically relative to another view.
    ///
    /// # Example:
    /// ``` swift
    /// view.center(to: anotherView)
    /// ```
    ///
    /// - Parameter view: The view to center relative to.
    /// - Returns: Self for chaining.
    @discardableResult
    func center(to view: UIView) -> Self {
        return centerX(to: view).centerY(to: view)
    }

    /// Pins the view's edges to another view with optional insets.
    ///
    /// # Example:
    /// ``` swift
    /// view.pinEdges(to: anotherView, insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    /// ```
    ///
    /// - Parameters:
    ///   - view: The view to pin edges to.
    ///   - insets: The edge insets for pinning. Default is zero.
    /// - Returns: Self for chaining.
    @discardableResult
    func pinEdges(to view: UIView, insets: UIEdgeInsets = .zero) -> Self {
        frame = CGRect(
            x: insets.left,
            y: insets.top,
            width: view.frame.width - insets.left - insets.right,
            height: view.frame.height - insets.top - insets.bottom
        )
        return self
    }
}
