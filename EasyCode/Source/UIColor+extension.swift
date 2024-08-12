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
    ///  let customColor = UIColor(hex: "#FFA500")
    ///  // Use customColor for UI elements
    ///  view.backgroundColor = customColor
    /// ```
    /// This example creates a UIColor object from the hex color string "#FFA500", which represents the color orange.
    convenience init(hex: String) {
        let hexColor = hex.filter { $0.isHexDigit }
        guard hexColor.count == 6 || hexColor.count == 8 else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }

        let scanner = Scanner(string: hexColor)
        var hexNumber = UInt64.zero
        guard scanner.scanHexInt64(&hexNumber) else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }

        if hexColor.count == 6 {
            let red = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            let green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            let blue = CGFloat((hexNumber & 0x0000ff)) / 255
            self.init(red: red, green: green, blue: blue, alpha: 1)
        } else {
            let red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            let green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            let blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            let alpha = CGFloat((hexNumber & 0x000000ff)) / 255
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
    }

    static var bg_black: UIColor { UIColor(hex: "#151E22") }
    static var bg_primary: UIColor { UIColor(hex: "#31AFC6") }
    static var sys_green: UIColor { UIColor(hex: "#24B651") }
    static var sys_grey: UIColor { UIColor(hex: "#D0D0D0") }

    /// Creates a dynamic `UIColor` that adapts to the user's interface style (light or dark mode).
    ///
    /// - Parameters:
    ///   - light: The color to be used in light mode.
    ///   - dark: The color to be used in dark mode.
    /// - Returns: A `UIColor` that dynamically switches between the provided light and dark colors based on the current user interface style.
    ///
    /// - Note: This method only works on iOS 13 and later. On earlier versions, the `light` color will be used as the default.
    ///
    /// # Example:
    /// ```swift
    /// let dynamicColor = UIColor.makeDynamicColor(
    ///     light: UIColor(hex: "#FFFFFF"),  // White color for light mode
    ///     dark: UIColor(hex: "#000000")    // Black color for dark mode
    /// )
    /// view.backgroundColor = dynamicColor
    /// ```
    /// In this example, the background color of the view will be white in light mode and black in dark mode.
    ///
    /// - Important: Ensure that the `light` and `dark` colors contrast well with each other to maintain readability and visual consistency in both modes.
    static func makeDynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        guard #available(iOS 13, *) else { return light }

        return UIColor { traits -> UIColor in
            switch traits.userInterfaceStyle {
            case .dark: return dark
            case .light, .unspecified: return light
            @unknown default: return light
            }
        }
    }
}
