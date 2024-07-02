//
//  Decimal+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension Decimal {

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

    func round(toPlaces decimalPlaces: Int) -> Decimal {
        var value = self
        var rounded = Self()
        NSDecimalRound(&rounded, &value, decimalPlaces, .bankers)
        return rounded
    }

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
