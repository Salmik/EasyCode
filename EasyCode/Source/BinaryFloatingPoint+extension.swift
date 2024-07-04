//
//  BinaryFloatingPoint+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension BinaryFloatingPoint {
    ///rounded: Returns a rounded value with the specified number of decimal places and rounding rule. If
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

    var string: String { return String(self) }
}

public extension Float {

    var string: String { return String(self) }

    func toString( _ precision: Int = 2) -> String { String(format: "%.\(precision)f", self) }
}

public extension Double {

    var string: String { return String(self) }

    func toString( _ precision: Int = 2) -> String { String(format: "%.\(precision)f", self) }
}
