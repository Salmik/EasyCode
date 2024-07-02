//
//  UIColor+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import UIKit

public extension UIColor {

    /// Initialize from integral RGB values (+ alpha channel in range 0-100)
    convenience init(rgb: UInt8..., alpha: UInt = 100) {
        self.init(
            red: CGFloat(rgb[0]) / 255,
            green: CGFloat(rgb[1]) / 255,
            blue: CGFloat(rgb[2]) / 255,
            alpha: CGFloat(min(alpha, 100)) / 100
        )
    }

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
}
