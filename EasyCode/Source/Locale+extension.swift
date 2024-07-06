//
//  Locale+extension.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

public extension Locale {

    /// Returns the POSIX locale.
    static var posix: Locale { Locale(identifier: "en_US_POSIX") }

    /// Retrieves the flag emoji for a given ISO country code.
    ///
    /// - Parameter isoRegionCode: The ISO country code.
    /// - Returns: The flag emoji corresponding to the country code.
    ///
    /// # Example:
    /// ``` swift
    /// if let flag = Locale.flagEmoji(forRegionCode: "US") {
    ///     print("Flag emoji for US: \(flag)")
    /// }
    /// ```
    static func flagEmoji(forRegionCode isoRegionCode: String) -> String? {
        return isoRegionCode.unicodeScalars.reduce(into: String()) {
            guard let flagScalar = UnicodeScalar(UInt32(127_397) + $1.value) else { return }
            $0.unicodeScalars.append(flagScalar)
        }
    }

    /// Retrieves a list of country names with their corresponding flag emojis.
    ///
    /// - Parameter localeIdentifier: Optional. The locale identifier to use for country names. Defaults to the current locale.
    /// - Returns: An array of strings representing country names with flag emojis.
    ///
    /// # Example:
    /// ``` swift
    /// let countries = Locale.listOfCountries()
    /// print("List of countries with flags: \(countries)")
    /// ```
    static func listOfCountries(localeIdentifier: String = Locale.current.identifier) -> [String] {
        var countryList: [String] = []
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: localeIdentifier)
                .displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Could not find country"
            let countryWithFlag = "\(name) \(countryFlag(country: code))"
            countryList.append(countryWithFlag)
        }
        return countryList
    }

    /// Retrieves the flag emoji for a given country code.
    ///
    /// - Parameter country: The two-letter ISO country code.
    /// - Returns: The flag emoji corresponding to the country code.
    ///
    /// # Example:
    /// ``` swift
    /// let flag = Locale.countryFlag(country: "US")
    /// print("Flag emoji for US: \(flag)")
    /// ```
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
