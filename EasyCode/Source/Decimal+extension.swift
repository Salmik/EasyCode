//
//  Decimal+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

/// Extension on `Decimal` providing utility methods for formatting and rounding.
public extension Decimal {

    /// Returns a formatted string representation of the decimal value.
    ///
    /// - Parameters:
    ///   - minimumFractionDigits: The minimum number of fraction digits to display.
    ///   - maximumFractionDigits: The maximum number of fraction digits to display.
    ///   - decimalSeparator: The string to use as the decimal separator (default: ".").
    ///   - groupingSeparator: The string to use as the grouping separator (default: " ").
    /// - Returns: A string representation of the decimal value formatted according to the specified parameters.
    ///
    /// # Example:
    /// ``` swift
    /// let amount: Decimal = 1234.5678
    /// let formattedAmount = amount.getDisplayedAmount(minimumFractionDigits: 2, maximumFractionDigits: 4)
    /// print(formattedAmount) // Output: "1 234.5678"
    /// ```
    func getDisplayedAmount(
        minimumFractionDigits: Int,
        maximumFractionDigits: Int,
        decimalSeparator: String = ".",
        groupingSeparator: String = " "
    ) -> String? {
        let number = NSDecimalNumber(decimal: self)
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = decimalSeparator
        numberFormatter.groupingSeparator = groupingSeparator
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = minimumFractionDigits
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        return numberFormatter.string(from: number)
    }

    /// Rounds the decimal value to a specified number of decimal places.
    ///
    /// - Parameter decimalPlaces: The number of decimal places to round to.
    /// - Returns: A new `Decimal` value rounded to the specified decimal places.
    ///
    /// # Example:
    /// ``` swift
    /// let amount: Decimal = 1234.5678
    /// let roundedAmount = amount.round(toPlaces: 2)
    /// print(roundedAmount) // Output: 1234.57
    /// ```
    func round(toPlaces decimalPlaces: Int) -> Decimal {
        var value = self
        var rounded = Self()
        NSDecimalRound(&rounded, &value, decimalPlaces, .bankers)
        return rounded
    }

    /// Returns a formatted percentage representation of the decimal value.
    ///
    /// - Returns: A string representation of the decimal value as a percentage.
    ///
    /// # Example:
    /// ``` swift
    /// let amount: Decimal = 0.75
    /// let percentString = amount.percent
    /// print(percentString) // Output: "75%"
    /// ```
    var percent: String {
        let string = String(format: "%.2f", NSDecimalNumber(decimal: self).doubleValue)
        let integerDigits = string.components(separatedBy: ".").first ?? ""
        var fractionDigits = string.components(separatedBy: ".").last ?? ""

        while fractionDigits.last == "0" { fractionDigits.removeLast() }

        if fractionDigits.isEmpty {
            return integerDigits + "%"
        } else {
            return [integerDigits, fractionDigits].joined(separator: ".") + "%"
        }
    }
}
