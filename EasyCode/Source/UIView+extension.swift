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
}
