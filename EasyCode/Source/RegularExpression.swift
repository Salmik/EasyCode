//
//  RegularExpression.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import Foundation

/// A struct that wraps around `NSRegularExpression` to provide a more Swift-friendly interface for regular expression operations.
public struct RegularExpression {

    private let regex: NSRegularExpression

    public init(regex: NSRegularExpression) {
        self.regex = regex
    }

    /// Finds all matches of the regular expression in the given string.
    /// - Parameters:
    ///   - string: The string to search for matches.
    ///   - options: The matching options to use. Default is an empty array.
    /// - Returns: An array of `NSTextCheckingResult` containing all matches.
    ///
    /// # Example:
    /// ``` swift
    /// let regex: RegularExpression = "\\d+"
    /// let matches = regex.matches(in: "The year is 2024")
    /// print(matches.count) // Output: 1
    /// ```
    public func matches(
        in string: String,
        options: NSRegularExpression.MatchingOptions = []
    ) -> [NSTextCheckingResult] {
        return regex.matches(in: string, options: options, range: NSRange(string.startIndex..., in: string))
    }

    /// Finds the first match of the regular expression in the given string and returns the specified subgroup.
    /// - Parameters:
    ///   - string: The string to search for matches.
    ///   - options: The matching options to use. Default is an empty array.
    ///   - subgroupPosition: The position of the subgroup to return. Default is 0.
    /// - Returns: The first matched substring or `nil` if no match is found.
    ///
    /// # Example:
    /// ``` c
    /// let regex: RegularExpression = "(\\d+)"
    /// if let firstMatch = regex.firstMatch(in: "The year is 2024") {
    ///     print(firstMatch) // Output: "2024"
    /// }
    /// ```
    public func firstMatch(
        in string: String,
        options: NSRegularExpression.MatchingOptions = [],
        subgroupPosition: Int = 0
    ) -> String? {
        let range = NSRange(string.startIndex..., in: string)
        guard let match = regex.firstMatch(in: string, options: options, range: range),
              let matchingRange = Range(match.range(at: subgroupPosition), in: string) else {
            return nil
        }
        return String(string[matchingRange])
    }

    /// Replaces all matches of the regular expression in the given string with the provided replacement string.
    /// - Parameters:
    ///   - string: The string in which to replace matches.
    ///   - replacement: The replacement string.
    ///   - options: The matching options to use. Default is an empty array.
    /// - Returns: A new string with all matches replaced.
    ///
    /// # Example:
    /// ``` swift
    /// let regex: RegularExpression = "\\d+"
    /// let replaced = regex.replaceMatches(in: "The year is 2024", with: "****")
    /// print(replaced) // Output: "The year is ****"
    /// ```
    public func replaceMatches(
        in string: String,
        with replacement: String,
        options: NSRegularExpression.MatchingOptions = []
    ) -> String {
        let range = NSRange(string.startIndex..., in: string)
        return regex.stringByReplacingMatches(in: string, options: options, range: range, withTemplate: replacement)
    }
}

extension RegularExpression: ExpressibleByStringLiteral {

    /// Initializes the `RegularExpression` with a string literal.
    /// - Parameter value: The string pattern to be used as the regular expression.
    ///
    /// # Example:
    /// ``` swift
    /// let regex: RegularExpression = "\\d+"
    /// ```
    public init(stringLiteral value: String) {
        guard let regex = try? NSRegularExpression(pattern: value, options: []) else {
            fatalError("Invalid Regex: \(value)")
        }
        self.init(regex: regex)
    }
}
