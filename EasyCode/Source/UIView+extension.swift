//
//  UIView+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit

public extension UIView {

    /// A computed property that returns a reuse identifier for the view.
    ///
    /// - Returns: A string representing the reuse identifier, typically the name of the view class.
    ///
    /// # Example:
    /// ``` swift
    /// let reuseId = MyCustomView.reuseId
    /// print(reuseId) // "MyCustomView"
    /// ```
    static var reuseId: String { String(describing: self) }

    /// A computed property that returns an image representation of the view.
    ///
    /// - Returns: An `UIImage` representing the current state of the view.
    ///
    /// # Example:
    /// ``` swift
    /// let image = myView.asImage
    /// imageView.image = image
    /// ```
    var asImage: UIImage {
        return autoreleasepool {
            UIGraphicsImageRenderer(size: bounds.size).image { _ in
                drawHierarchy(in: bounds, afterScreenUpdates: true)
            }
        }
    }

    /// Rotates the view by the specified number of degrees.
    ///
    /// - Parameter degrees: The number of degrees to rotate the view.
    ///
    /// # Example:
    /// ``` swift
    /// myView.rotate(degrees: 45)
    /// ```
    func rotate(degrees: CGFloat) {
        let radians = degrees * .pi / 180
        transform = CGAffineTransform(rotationAngle: radians)
    }

    /// Adds a border to the view with the specified width and color.
    ///
    /// - Parameters:
    ///   - width: The width of the border.
    ///   - color: The color of the border.
    ///
    /// # Example:
    /// ``` swift
    /// myView.addBorder(width: 2, color: .red)
    /// ```
    func addBorder(width: CGFloat, color: UIColor) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }

    /// Adds a shadow to the view with the specified properties.
    ///
    /// - Parameters:
    ///   - color: The color of the shadow. Default is black.
    ///   - opacity: The opacity of the shadow. Default is 0.5.
    ///   - radius: The blur radius of the shadow. Default is 5.
    ///   - offset: The offset of the shadow. Default is `.zero`.
    ///
    /// # Example:
    /// ``` swift
    /// myView.addShadow(color: .black, opacity: 0.7, radius: 10, offset: CGSize(width: 3, height: 3))
    /// ```
    func addShadow(
        color: UIColor = .black,
        opacity: Float = 0.5,
        radius: CGFloat = 5,
        offset: CGSize = .zero
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
    }

    /// Adds a gradient to the view with the specified properties.
    ///
    /// - Parameters:
    ///   - colors: An array of `UIColor` objects defining the gradient colors.
    ///   - locations: An array of `NSNumber` objects defining the location of each gradient stop.
    ///   - startPoint: The starting point of the gradient in the coordinate space of the layer.
    ///   - endPoint: The ending point of the gradient in the coordinate space of the layer.
    ///
    /// # Example:
    /// ``` swift
    /// myView.addGradient(
    ///     colors: [.red, .blue],
    ///     locations: [0, 1],
    ///     startPoint: CGPoint(x: 0, y: 0),
    ///     endPoint: CGPoint(x: 1, y: 1)
    /// )
    /// ```
    func addGradient(
        colors: [UIColor],
        locations: [NSNumber]?,
        startPoint: CGPoint,
        endPoint: CGPoint
    ) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        layer.insertSublayer(gradientLayer, at: 0)
    }

    /// Rounds the specified corners of the view with the given radius.
    ///
    /// - Parameters:
    ///   - corners: The corners to round.
    ///   - radius: The radius for the rounded corners.
    ///
    /// # Example:
    /// ``` swift
    /// myView.roundCorners(corners: [.topLeft, .bottomRight], radius: 10)
    /// ```
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    /// Applies a shake animation to the view.
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]
        animation.values = [-10, 10, -8, 8, -6, 6, -4, 4, 0]
        layer.add(animation, forKey: "shake")
    }

    /// Removes all subviews from the view.
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    /// Adds a shimmer effect to the view.
    func addShimmerEffect() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.75).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = self.bounds
        let angle = 45 * CGFloat.pi / 180
        gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        layer.mask = gradientLayer

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 2
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.repeatCount = .infinity

        gradientLayer.add(animation, forKey: "shimmer")
    }

    /// A comprehensive utility method to simplify and streamline the setup of Auto Layout constraints programmatically.
    ///
    /// - Parameters:
    ///   - top: Constrains the top anchor to the specified `NSLayoutYAxisAnchor`. Defaults to `nil`.
    ///   - paddingTop: Padding from the top anchor. Defaults to `0`.
    ///   - bottom: Constrains the bottom anchor to the specified `NSLayoutYAxisAnchor`. Defaults to `nil`.
    ///   - paddingBottom: Padding from the bottom anchor. Defaults to `0`.
    ///   - leading: Constrains the leading anchor to the specified `NSLayoutXAxisAnchor`. Defaults to `nil`.
    ///   - paddingLeading: Padding from the leading anchor. Defaults to `0`.
    ///   - trailing: Constrains the trailing anchor to the specified `NSLayoutXAxisAnchor`. Defaults to `nil`.
    ///   - paddingTrailing: Padding from the trailing anchor. Defaults to `0`.
    ///   - safeArea: If `true`, uses safe area anchors for top, bottom, leading, and trailing. Defaults to `false`.
    ///   - centerX: Constrains the centerX anchor to the specified `NSLayoutXAxisAnchor`. Defaults to `nil`.
    ///   - paddingCenterX: Offset for the centerX anchor. Defaults to `0`.
    ///   - centerY: Constrains the centerY anchor to the specified `NSLayoutYAxisAnchor`. Defaults to `nil`.
    ///   - paddingCenterY: Offset for the centerY anchor. Defaults to `0`.
    ///   - width: Fixed width constraint. If `0`, no width constraint is applied. Defaults to `0`.
    ///   - height: Fixed height constraint. If `0`, no height constraint is applied. Defaults to `0`.
    ///   - dynamicWidth: Constrains width using another `NSLayoutDimension`. Defaults to `nil`.
    ///   - dynamicHeight: Constrains height using another `NSLayoutDimension`. Defaults to `nil`.
    ///   - aspectRatio: Aspect ratio (width divided by height). Overrides width and height if specified. Defaults to `nil`.
    ///   - priority: Priority for constraints. Defaults to `.required`.
    ///
    func setupAnchors(
        top: NSLayoutYAxisAnchor? = nil,
        paddingTop: CGFloat = 0,
        bottom: NSLayoutYAxisAnchor? = nil,
        paddingBottom: CGFloat = 0,
        leading: NSLayoutXAxisAnchor? = nil,
        paddingLeading: CGFloat = 0,
        trailing: NSLayoutXAxisAnchor? = nil,
        paddingTrailing: CGFloat = 0,
        safeArea: Bool = false,
        centerX: NSLayoutXAxisAnchor? = nil,
        paddingCenterX: CGFloat = 0,
        centerY: NSLayoutYAxisAnchor? = nil,
        paddingCenterY: CGFloat = 0,
        width: CGFloat = 0,
        height: CGFloat = 0,
        dynamicWidth: NSLayoutDimension? = nil,
        dynamicHeight: NSLayoutDimension? = nil,
        aspectRatio: CGFloat? = nil,
        priority: UILayoutPriority = .required
    ) {
        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            let anchor = safeArea ? superview?.safeAreaLayoutGuide.topAnchor ?? top : top
            let constraint = topAnchor.constraint(equalTo: anchor, constant: paddingTop)
            constraint.priority = priority
            constraint.isActive = true
        }

        if let bottom = bottom {
            let anchor = safeArea ? superview?.safeAreaLayoutGuide.bottomAnchor ?? bottom : bottom
            let constraint = bottomAnchor.constraint(equalTo: anchor, constant: -paddingBottom)
            constraint.priority = priority
            constraint.isActive = true
        }

        if let leading = leading {
            let anchor = safeArea ? superview?.safeAreaLayoutGuide.leadingAnchor ?? leading : leading
            let constraint = leadingAnchor.constraint(equalTo: anchor, constant: paddingLeading)
            constraint.priority = priority
            constraint.isActive = true
        }

        if let trailing = trailing {
            let anchor = safeArea ? superview?.safeAreaLayoutGuide.trailingAnchor ?? trailing : trailing
            let constraint = trailingAnchor.constraint(equalTo: anchor, constant: -paddingTrailing)
            constraint.priority = priority
            constraint.isActive = true
        }

        if let centerX = centerX {
            let constraint = centerXAnchor.constraint(equalTo: centerX, constant: paddingCenterX)
            constraint.priority = priority
            constraint.isActive = true
        }

        if let centerY = centerY {
            let constraint = centerYAnchor.constraint(equalTo: centerY, constant: paddingCenterY)
            constraint.priority = priority
            constraint.isActive = true
        }

        if width != 0 {
            let constraint = widthAnchor.constraint(equalToConstant: width)
            constraint.priority = priority
            constraint.isActive = true
        }

        if height != 0 {
            let constraint = heightAnchor.constraint(equalToConstant: height)
            constraint.priority = priority
            constraint.isActive = true
        }

        if let dynamicWidth = dynamicWidth {
            let constraint = widthAnchor.constraint(equalTo: dynamicWidth)
            constraint.priority = priority
            constraint.isActive = true
        }

        if let dynamicHeight = dynamicHeight {
            let constraint = heightAnchor.constraint(equalTo: dynamicHeight)
            constraint.priority = priority
            constraint.isActive = true
        }

        if let aspectRatio = aspectRatio {
            let constraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: aspectRatio)
            constraint.priority = priority
            constraint.isActive = true
        }
    }
}
