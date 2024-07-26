//
//  UIColor+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit

public extension UIColor {

    /// Initializes a color object using the specified opacity and RGB component values.
    ///
    /// - Parameters:
    ///   - rgb: A variadic parameter representing the red, green, and blue color components as values from 0 to 255.
    ///   - alpha: The opacity value of the color object, specified as a value from 0 to 100. The default is 100.
    /// - Note: If the number of RGB values is not exactly 3, the behavior is undefined.
    ///
    /// # Example:
    /// ``` swift
    /// let customColor = UIColor(rgb: 100, 200, 50, alpha: 80)
    /// ```
    /// This creates a UIColor object with RGB values (100, 200, 50) and alpha value 0.8 (80% opacity).
    ///
    /// If you provide fewer than 3 RGB values or more than 3, the behavior is not guaranteed.
    convenience init(rgb: UInt8..., alpha: UInt = 100) {
        self.init(
            red: CGFloat(rgb[0]) / 255,
            green: CGFloat(rgb[1]) / 255,
            blue: CGFloat(rgb[2]) / 255,
            alpha: CGFloat(min(alpha, 100)) / 100
        )
    }

    /// Initializes a color object using the specified hex string.
    ///
    /// - Parameter hex: The hex string representation of the color. It should start with '#' and be followed by exactly 6 hex digits.
    /// - Returns: A UIColor object if the hex string is valid, otherwise `nil`.
    ///
    /// # Example:
    /// ``` swift
    /// if let customColor = UIColor(hex: "#FFA500") {
    ///     // Use customColor for UI elements
    ///     view.backgroundColor = customColor
    /// } else {
    ///     print("Invalid hex color format.")
    /// }
    /// ```
    /// This example creates a UIColor object from the hex color string "#FFA500", which represents the color orange.
    convenience init?(hex: String) {
        guard hex.hasPrefix("#") else { return nil }

        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        guard hexColor.count == 6 else { return nil }

        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { return nil }

        let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
        let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
        let b = CGFloat((hexNumber & 0x0000ff)) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }

    static var bg_black: UIColor { UIColor(hex: "#151E22") ?? .black }
    static var bg_primary: UIColor { UIColor(hex: "#31AFC6") ?? .black }
    static var sys_green: UIColor { UIColor(hex: "#24B651") ?? .black }
    static var sys_grey: UIColor { UIColor(hex: "#D0D0D0") ?? .black }

    static func makeDynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        guard #available(iOS 13, *) else { return light }

        return UIColor { (traits) -> UIColor in
            switch traits.userInterfaceStyle {
            case .dark: return dark
            case .light, .unspecified: return light
            @unknown default: return light
            }
        }
    }
}
