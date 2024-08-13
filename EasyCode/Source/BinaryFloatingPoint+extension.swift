//
//  BinaryFloatingPoint+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension BinaryFloatingPoint {
    /// rounded: Returns a rounded value with the specified number of decimal places and rounding rule. If
    /// `numberOfDecimalPlaces` is negative, `0` will be used.
    ///
    ///     let num = 3.1415927
    ///     num.rounded(numberOfDecimalPlaces: 3, rule: .up) -> 3.142
    ///     num.rounded(numberOfDecimalPlaces: 3, rule: .down) -> 3.141
    ///     num.rounded(numberOfDecimalPlaces: 2, rule: .awayFromZero) -> 3.15
    ///     num.rounded(numberOfDecimalPlaces: 4, rule: .towardZero) -> 3.1415
    ///     num.rounded(numberOfDecimalPlaces: -1, rule: .toNearestOrEven) -> 3
    ///
    /// - Parameters:
    ///   - numberOfDecimalPlaces: The expected number of decimal places.
    ///   - rule: The rounding rule to use.
    /// - Returns: The rounded value.
    func rounded(numberOfDecimalPlaces: Int, rule: FloatingPointRoundingRule) -> Self {
        let factor = Self(pow(10.0, Double(max(0, numberOfDecimalPlaces))))
        return (self * factor).rounded(rule) / factor
    }
}

public extension Int {

    /// Converts the integer to a string.
    ///
    /// - Returns: A string representation of the integer.
    ///
    /// # Example:
    /// ``` swift
    /// let number = 42
    /// print(number.string) // "42"
    /// ```
    var string: String { String(self) }
}

public extension Float {

    /// Converts the float to a string.
    ///
    /// - Returns: A string representation of the float.
    ///
    /// # Example:
    /// ``` swift
    /// let number: Float = 3.14
    /// print(number.string) // "3.14"
    /// ```
    var string: String { String(self) }

    /// Converts the float to a string with a specified precision.
    ///
    /// - Parameter precision: The number of decimal places to include in the string. Default is 2.
    /// - Returns: A string representation of the float with the specified precision.
    ///
    /// # Example:
    /// ``` swift
    /// let number: Float = 3.14159
    /// print(number.toString()) // "3.14"
    /// print(number.toString(3)) // "3.142"
    /// ```
    func toString(_ precision: Int = 2) -> String { String(format: "%.\(precision)f", self) }
}

public extension Double {

    /// Converts the double to a string.
    ///
    /// - Returns: A string representation of the double.
    ///
    /// # Example:
    /// ``` swift
    /// let number: Double = 3.14
    /// print(number.string) // "3.14"
    /// ```
    var string: String { String(self) }

    /// Converts the double to a string with a specified precision.
    ///
    /// - Parameter precision: The number of decimal places to include in the string. Default is 2.
    /// - Returns: A string representation of the double with the specified precision.
    ///
    /// # Example:
    /// ``` swift
    /// let number: Double = 3.14159
    /// print(number.toString()) // "3.14"
    /// print(number.toString(3)) // "3.142"
    /// ```
    func toString(_ precision: Int = 2) -> String { String(format: "%.\(precision)f", self) }
}
