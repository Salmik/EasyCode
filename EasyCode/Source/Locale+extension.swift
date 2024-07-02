//
//  Locale+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension Locale {

    static var posix: Locale { Locale(identifier: "en_US_POSIX") }

    static func flagEmoji(forRegionCode isoRegionCode: String) -> String? {
        return isoRegionCode.unicodeScalars.reduce(into: String()) {
            guard let flagScalar = UnicodeScalar(UInt32(127_397) + $1.value) else { return }
            $0.unicodeScalars.append(flagScalar)
        }
    }

    static func listOfCountries(localeIdentifier: String = "en") -> [String] {
        var countryList: [String] = []
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: localeIdentifier)
                .displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Could not found code"
            countryList.append(name + " " + countryFlag(country: code))
        }
        return countryList
    }

    static func countryFlag(country: String) -> String {
        let base: UInt32 = 127397
        var string = ""
        for countryUnicode in country.unicodeScalars {
            guard let unicode = UnicodeScalar(base + countryUnicode.value) else { continue }
            string.unicodeScalars.append(unicode)
        }
        return String(string)
    }
}
